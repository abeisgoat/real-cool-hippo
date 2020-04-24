import 'package:universal_html/html.dart';

import "game_state.dart";
import 'master_deck.dart';
import "cards.dart";
import "card_bundle.dart";
import 'dart:math' as math;
import 'seed.dart';

class PlayerAction {
  final String playerId;
  final int cardId;

  PlayerAction({this.playerId, this.cardId});
}

enum LegalResponse {
  NoJudgement,
  Accepted,
  Rejected_DrawRequired,
  Rejected_NotYourTurn,
  Rejected_CardNotHeld,
  Rejected_InvalidCardPlay
}

class Ruleset {
  static MasterDeck newMasterDeck() {
    List<Card> cards = [];
    for (var color in CardColor.values) {
      for (var number = 0; number <= 9; number++) {
        for (var copies = 1; copies <= 2; copies++) {
          cards.add(NumberCard(number: number, color: color, id: cards.length));
        }
      }

      for (var skips = 0; skips < 2; skips++) {
        cards.add(ActionCard(
            color: color, action: CardAction.Skip, id: cards.length));
        cards.add(ActionCard(
            color: color, action: CardAction.Reverse, id: cards.length));
        cards.add(ActionCard(
            color: color, action: CardAction.DrawTwo, id: cards.length));
      }
    }

    for (var wilds = 0; wilds < 4; wilds++) {
      cards.add(WildCard(action: WildCardAction.DrawNone, id: cards.length));
      cards.add(WildCard(action: WildCardAction.DrawFour, id: cards.length));
    }

    cards.add(CommandCard(
        command: "Wild_Pick", id: cards.length, color: CardColor.Blue)); // 108
    cards.add(CommandCard(
        command: "Wild_Pick", id: cards.length, color: CardColor.Red)); // 109
    cards.add(CommandCard(
        command: "Wild_Pick",
        id: cards.length,
        color: CardColor.Yellow)); // 110
    cards.add(CommandCard(
        command: "Wild_Pick", id: cards.length, color: CardColor.Green)); // 111
    cards.add(CommandCard(command: "DrawRequired", id: cards.length)); // 112
    cards.add(CommandCard(command: "DrawRequired", id: cards.length)); // 113
    cards.add(CommandCard(command: "DrawRequired", id: cards.length)); // 114
    cards.add(CommandCard(command: "DrawRequired", id: cards.length)); // 115
    cards.add(CommandCard(command: "Turn++", id: cards.length)); // 116
    cards.add(CommandCard(command: "Turn--", id: cards.length)); // 117
    cards.add(CommandCard(
        command: "Wild_PickDraw4",
        id: cards.length,
        color: CardColor.Blue)); // 118
    cards.add(CommandCard(
        command: "Wild_PickDraw4",
        id: cards.length,
        color: CardColor.Red)); // 119
    cards.add(CommandCard(
        command: "Wild_PickDraw4",
        id: cards.length,
        color: CardColor.Yellow)); // 120
    cards.add(CommandCard(
        command: "Wild_PickDraw4",
        id: cards.length,
        color: CardColor.Green)); // 121

    return MasterDeck(cards: cards);
  }

  static GameStateSnapshot newGame({List<String> players, math.Random seed}) {
    var md = Ruleset.newMasterDeck();
    var gss = GameStateSnapshot();
    var deck = CardBundle(masterDeck: md, useReverseSerialization: true);

    for (var card in md.getCards()) {
      deck.addCardByID(card.id);
    }

    gss.bundles["^deck"] = deck;

    gss.livePlayer = seed.nextInt(players.length);

    for (var pIndex = 0; pIndex < players.length; pIndex++) {
      var playerBundle = CardBundle(masterDeck: md);

      for (var draw = 0; draw < 7; draw++) {
        var cardId = deck.getRandomCardID(seed);
        playerBundle.transferCardByID(from: deck, id: cardId);
      }

      if (gss.livePlayer == pIndex) {
        playerBundle.addCardByID(md.cc("Turn++"));
      }

      gss.bundles[players[pIndex]] = playerBundle;
    }

    gss.masterDeck = md;

    var numberCardIds = gss.bundles["^deck"]
        .getCards()
        .where((card) => card is NumberCard)
        .map((card) => card.id)
        .toList();

    gss.bundles["^discard"] = CardBundle(masterDeck: md);
    gss.liveCardId = numberCardIds[seed.nextInt(numberCardIds.length)];
    gss.bundles["^discard"].transferCardByID(from: deck, id: gss.liveCardId);
    gss.turnsPlayed = 0;

    return gss;
  }

  static GameStateSnapshot play(
      {GameStateSnapshot before, PlayerAction playerAction}) {
    var md = before.masterDeck;
    var card = md.getCardByID(playerAction.cardId);
    var after = before.clone();
    var hand = after.getPlayerBundle(playerAction.playerId);

    var legalResponse = Ruleset.isPlayLegal(
        before: before, playerAction: playerAction, hand: hand);

    if (legalResponse != LegalResponse.Accepted) {
      print(legalResponse);
      return before;
    }

    if (after.bundles["^deck"].getCards().length < 3) {
      after.bundles["^discard"].getCards().forEach((card) {
        after.bundles["^deck"]
            .transferCardByID(from: after.bundles["^discard"], id: card.id);
      });
    }

    if (card is NumberCard) {
      after.liveCardId = card.id;
      after.bundles["^discard"].transferCardByID(from: hand, id: card.id);
      after = Ruleset.endTurn(before: after);
    }

    if (card is ActionCard) {
      after.liveCardId = card.id;
      after.bundles["^discard"].transferCardByID(from: hand, id: card.id);

      // If the card is a Reverse then swap Turn-- | Turn++
      if (card.action == CardAction.Reverse) {
        if (hand.hasCardByID(md.cc("Turn++"))) {
          hand.removeCardByID(md.cc("Turn++"));
          hand.addCardByID(md.cc("Turn--"));
        } else if (hand.hasCardByID(md.cc("Turn--"))) {
          hand.removeCardByID(md.cc("Turn--"));
          hand.addCardByID(md.cc("Turn++"));
        }
        after = Ruleset.endTurn(before: after);
      }

      if (card.action == CardAction.Skip) {
        // just do an extra turn end ezpz
        after = Ruleset.endTurn(before: after);
        after = Ruleset.endTurn(before: after);
      }

      if (card.action == CardAction.DrawTwo) {
        after = Ruleset.endTurn(before: after);
        var nextPlayerHand = after.getPlayerBundleByIndex(after.livePlayer);

        nextPlayerHand.addCardsByID(md.ccs("DrawRequired").sublist(0, 2));
      }
    }

    if (card is WildCard) {
      after.liveCardId = card.id;
      after.bundles["^discard"].transferCardByID(from: hand, id: card.id);

      if (card.action == WildCardAction.DrawNone) {
        hand.addCardsByID(md.ccs("Wild_Pick"));
      }

      if (card.action == WildCardAction.DrawFour) {
        hand.addCardsByID(md.ccs("Wild_PickDraw4"));
      }
    }

    if (card is CommandCard) {
      // Playing the Turn card is how you draw, yeah a little weird
      if (card.command.startsWith("Turn")) {
        hand.transferCardByID(
            from: after.bundles["^deck"],
            id: after.bundles["^deck"].getRandomCardID(Seed(after.toString())));

        var hasFulfilledDrawRequired = false;
        for (var drawRequiredId in md.ccs("DrawRequired")) {
          if (hand.hasCardByID(drawRequiredId)) {
            hand.removeCardByID(drawRequiredId);
            hasFulfilledDrawRequired = true;
            break;
          }
        }

//        if (hasFulfilledDrawRequired) {
//          var remainingDrawRequirments = hand
//              .getCards()
//              .where((card) => md.ccs("DrawRequired").contains(card.id))
//              .length;
//
////          if (remainingDrawRequirments == 0) {
////            after = Ruleset.endTurn(before: after);
////          }
//        }
      }

      if (card.command.startsWith("Wild")) {
        // Remove all wild choices from player hand
        hand.removeCardsByID(md.ccs("Wild_Pick"), quiet: true);
        hand.removeCardsByID(md.ccs("Wild_PickDraw4"), quiet: true);

        var beforeCard = md.getCardByID(after.liveCardId);
        after.liveCardId = card.id;
        after = Ruleset.endTurn(before: after);

        if (beforeCard is WildCard &&
            beforeCard.action == WildCardAction.DrawFour) {
          var nextPlayerHand = after.getPlayerBundleByIndex(after.livePlayer);

          nextPlayerHand.addCardsByID(md.ccs("DrawRequired"));
        }
      }
    }

    if (isGameover(after: after)) {
      after.score = getGameScore(after: after);
    }

    return after;
  }

  static isGameover({GameStateSnapshot after}) {
    if (after.turnsPlayed >= 100) {
      return true;
    }

    return after.bundles.entries.where((pair) {
          if (pair.key.startsWith("^")) return false;

          return pair.value.getCards().length == 0;
        }).length >
        0;
  }

  static getGameScore({GameStateSnapshot after}) {
    var playerBundles = after.bundles.entries
        .where((pair) => !pair.key.startsWith("^"))
        .toList();
    playerBundles
        .sort((a, b) => a.value.getCards().length - b.value.getCards().length);

    Map<String, int> scores = {};
    var index = 0;
    playerBundles.forEach((pair) {
      scores[pair.key] = (playerBundles.length - index) * 100;

      pair.value.getCards().forEach((card) {
        scores[pair.key] -= Ruleset.getCardPoints(card);
      });

      scores[pair.key] =
          (math.max(0, scores[pair.key]) / playerBundles.length).ceil();
      index += 1;
    });

    return scores;
  }

  static getCardPoints(Card card) {
    if (card is NumberCard) {
      return card.number;
    } else if (card is ActionCard) {
      return 10;
    } else if (card is WildCard) {
      return 15;
    }

    return 0;
  }

  static endTurn({GameStateSnapshot before}) {
    var hand = before.getPlayerBundleByIndex(before.livePlayer);

    var direction = hand.hasCardByID(before.masterDeck.cc("Turn++")) ? 1 : -1;
    var playerCount = before.getPlayerCount();

    before.livePlayer += direction;
    before.livePlayer %= playerCount;

    if (before.livePlayer < 0) {
      before.livePlayer += playerCount;
    }

    var nextLivePlayerHand = before.getPlayerBundleByIndex(before.livePlayer);

    // Pass draw and turn cards to next player
    [before.masterDeck.cc("Turn--"), before.masterDeck.cc("Turn++")]
        .forEach((id) {
      if (hand.hasCardByID(id))
        nextLivePlayerHand.transferCardByID(from: hand, id: id);
    });

    before.turnsPlayed++;

    return before;
  }

  static LegalResponse isPlayLegal(
      {GameStateSnapshot before, CardBundle hand, PlayerAction playerAction}) {
    var md = before.masterDeck;

    // If the player isn't attempting to draw, make sure they're not required to draw
    if (playerAction.cardId != md.cc("Turn++") &&
        playerAction.cardId != md.cc("Turn--")) {
      for (var drawRequiredId in md.ccs("DrawRequired")) {
        if (hand.hasCardByID(drawRequiredId)) {
          return LegalResponse.Rejected_DrawRequired;
        }
      }
    }

    // Is the person playing this card the person who's turn it is?
    if (!hand.hasCardByID(md.cc("Turn++")) &&
        !hand.hasCardByID(md.cc("Turn--")))
      return LegalResponse.Rejected_NotYourTurn;

    // Does the player actually have the card they're trying to play?
    if (!hand.hasCardByID(playerAction.cardId)) {
      return LegalResponse.Rejected_CardNotHeld;
    }

    var card = md.getCardByID(playerAction.cardId);
    var liveCard = md.getCardByID(before.liveCardId);

    if (card is CommandCard) {
      return LegalResponse.Accepted;
    }

    if (card is WildCard) {
      return LegalResponse.Accepted;
    }

    if (card.color == liveCard.color) {
      return LegalResponse.Accepted;
    }

    if (card is NumberCard &&
        liveCard is NumberCard &&
        liveCard.number == card.number) {
      return LegalResponse.Accepted;
    }

    if (card is ActionCard &&
        liveCard is ActionCard &&
        liveCard.action == card.action) {
      return LegalResponse.Accepted;
    }

    return LegalResponse.Rejected_InvalidCardPlay;
  }
}
