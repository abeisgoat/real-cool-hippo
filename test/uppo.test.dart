import 'package:test/test.dart';
import '../lib/uppo/uppo.dart' as uppo;

void main() {
  group("CardBundle", () {
    var deck = uppo.Ruleset.newMasterDeck();

    group("serialization", () {
      test('when straight and empty should be short', () {
        var cb = uppo.CardBundle(masterDeck: deck);
        expect(cb.toString(), equals('+0.0.0.0'));
      });

      test('when straight and full should be long', () {
        var cb = uppo.CardBundle(masterDeck: deck);

        for (var card in deck.getCards(includeCommands: true)) {
          cb.addCardByID(card.id);
        }

        expect(cb.toString(),
            equals('+4294967295.4294967295.4294967295.1073741823'));
      });

      test('when reverse and empty should be short', () {
        var cb =
            uppo.CardBundle(masterDeck: deck, useReverseSerialization: true);

        for (var card in deck.getCards(includeCommands: true)) {
          cb.addCardByID(card.id);
        }

        expect(cb.toString(), equals('-0.0.0.0'));
      });

      test('when reverse and full should long', () {
        var cb =
            uppo.CardBundle(masterDeck: deck, useReverseSerialization: true);
        expect(cb.toString(),
            equals('-4294967295.4294967295.4294967295.1073741823'));
      });

      test('should create bundle from serialization', () {
        var ancestorCb = uppo.CardBundle(masterDeck: deck);
        List<int> cardsToAdd = [21, 42, 23, 1, 34, 59];

        for (var id in cardsToAdd) {
          ancestorCb.addCardByID(id);
        }

        var deserializedCb = uppo.CardBundle.fromString(
            masterDeck: deck, string: ancestorCb.toString());

        expect(deserializedCb.getCards(), equals(ancestorCb.getCards()));
      });

      test('should allow boundaries to be played', () {
        var ancestorCb = uppo.CardBundle(masterDeck: deck);
        List<int> cardsToAdd = [1, 31, 32, 63, 64, 95, 96];

        for (var id in cardsToAdd) {
          ancestorCb.addCardByID(id);
        }

        var deserializedCb = uppo.CardBundle.fromString(
            masterDeck: deck, string: ancestorCb.toString());

        expect(deserializedCb.getCards(), equals(ancestorCb.getCards()));
      });
    });

    group("diff", () {
      test("should provide operation log of changes", () {
        var cb = uppo.CardBundle(masterDeck: deck);
        List<int> cardsToAdd = [21, 42, 23, 1, 34, 59];

        for (var id in cardsToAdd) {
          cb.addCardByID(id);
        }

        var otherCb =
            uppo.CardBundle.fromString(masterDeck: deck, string: cb.toString());

        List<int> otherCardsToAdd = [87, 89];

        for (var id in otherCardsToAdd) {
          otherCb.addCardByID(id);
        }

        List<int> otherCardsToRemove = [21, 1, 34];
        for (var id in otherCardsToRemove) {
          otherCb.removeCardByID(id);
        }

        expect(
            cb.diff(otherCb),
            equals([
              uppo.CardBundleOperation(
                  action: uppo.CardBundleOperationAction.Added, card: 87),
              uppo.CardBundleOperation(
                  action: uppo.CardBundleOperationAction.Added, card: 89),
              uppo.CardBundleOperation(
                  action: uppo.CardBundleOperationAction.Removed, card: 21),
              uppo.CardBundleOperation(
                  action: uppo.CardBundleOperationAction.Removed, card: 1),
              uppo.CardBundleOperation(
                  action: uppo.CardBundleOperationAction.Removed, card: 34)
            ]));
      });
    });
  });

  group("GameStateSnapshot", () {
    group("diff", () {
      test('should specify card movements between bundles', () {
        var masterDeck = uppo.Ruleset.newMasterDeck();
        var gss = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));
        var originalGss = uppo.GameStateSnapshot.fromMap(
            masterDeck: masterDeck, map: gss.toMap());

        var drawSeed = uppo.Seed("TTCT");

        var deck = gss.bundles["^deck"];
        var playerZeroBundle = gss.bundles["abc"];
        var playerOneBundle = gss.bundles["def"];

        playerZeroBundle.transferCardByID(
            from: deck, id: deck.getRandomCardID(drawSeed));

        playerOneBundle.transferCardByID(
            from: deck, id: deck.getRandomCardID(drawSeed));

        expect(
            gss.diff(originalGss),
            equals({
              13: uppo.CardMovement(from: "^deck", to: "abc"),
              10: uppo.CardMovement(from: "^deck", to: "def"),
            }));
      });
    });

    group("toMap", () {
      test("should serialize to map", () {
        var drawSeed = uppo.Seed("TTCT");
        var gss = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));
        var deck = gss.bundles["^deck"];
        var playerZeroBundle = gss.getPlayerBundleByIndex(0);

        for (var d = 0; d < 3; d++) {
          playerZeroBundle.transferCardByID(
              from: deck, id: deck.getRandomCardID(drawSeed));
        }

        expect(gss.toMap(), {
          'b': {
            '^deck': '-285288192.3221233664.234885152.1073697792',
            'abc': '+16786944.2147491840.100667392.16793600',
            'def': '+268501248.1073741824.32.5120',
            '^discard': '+0.0.134217728.0'
          },
          'l': 91,
          'a': 0,
          't': 0,
          '_d': 1,
          '_c': {'^deck': 94, 'abc': 11, 'def': 7, '^discard': 1}
        });
      });
    });

    group("fromMap", () {
      test("should desrialize from Map", () {
        var deck = uppo.Ruleset.newMasterDeck();
        var map = {
          'b': {
            'deck': '-32.32768.0.16384',
            'discard': '+0.0.0.0',
            'p:0': '+32.32768.0.16384',
            'p:1': '+0.0.67108864.0'
          },
          'l': 51,
          'a': 1,
          't': 33,
          '_d': -1,
          '_c': {'deck': 123, 'discard': 0, 'p:0': 3, 'p:1': 1}
        };

        var gss = uppo.GameStateSnapshot.fromMap(masterDeck: deck, map: map);

        expect(gss.toMap(), equals(map));
      });
    });
  });

  group("Ruleset", () {
    test('should have 112 cards', () {
      var deck = uppo.Ruleset.newMasterDeck();
      expect(deck.getCards().length, equals(112));
    });

    group("play", () {
      test("should step livePlayer", () {
        var before = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));
        before.liveCardId = 21;
        before.getPlayerBundle("abc").addCardByID(before.liveCardId);

        var after = uppo.Ruleset.play(
            before: before,
            playerAction:
                uppo.PlayerAction(cardId: before.liveCardId, playerId: "abc"));

        expect(before.livePlayer, equals(0));
        expect(after.livePlayer, equals(1));
      });

      test("should remove number card and turn command from hand", () {
        var before = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));

        var after = uppo.Ruleset.play(
            before: before,
            playerAction: uppo.PlayerAction(
                cardId: before
                    .getPlayerBundleByIndex(before.livePlayer)
                    .getCards()[5]
                    .id,
                playerId: "abc"));

        var beforeCardCount =
            before.getPlayerBundleByIndex(before.livePlayer).getCards().length;
        var afterCardCount =
            after.getPlayerBundleByIndex(before.livePlayer).getCards().length;

        expect(afterCardCount, equals(beforeCardCount - 2));
      });
    });

    group("isPlayLegal", () {
      test("should reject attempts to play when it's not your turn", () {
        var game = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));

        var approval = uppo.Ruleset.isPlayLegal(
            before: game,
            hand: game.bundles["def"],
            playerAction: uppo.PlayerAction(cardId: 23, playerId: "def"));

        expect(approval, equals(uppo.LegalResponse.Rejected_NotYourTurn));
      });

      test("should reject attempts to play if you don't hold the card", () {
        var game = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));

        var approval = uppo.Ruleset.isPlayLegal(
            before: game,
            hand: game.bundles["abc"],
            playerAction: uppo.PlayerAction(cardId: 23, playerId: "abc"));

        expect(approval, equals(uppo.LegalResponse.Rejected_CardNotHeld));
      });

      test("should reject attempts to play if the color / number doesn't match",
          () {
        var game = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));

        var approval = uppo.Ruleset.isPlayLegal(
            before: game,
            hand: game.bundles["abc"],
            playerAction: uppo.PlayerAction(
                cardId: game.bundles["abc"].getCards()[0].id,
                playerId: "abc"));

        expect(approval, equals(uppo.LegalResponse.Rejected_InvalidCardPlay));
      });

      test("should accept if number / color does match", () {
        var game = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));

        var approval = uppo.Ruleset.isPlayLegal(
            before: game,
            hand: game.bundles["abc"],
            playerAction: uppo.PlayerAction(
                cardId: game.bundles["abc"].getCards()[6].id,
                playerId: "abc"));

        expect(approval, equals(uppo.LegalResponse.Accepted));
      });

      test("should accept if card played is wild", () {
        var game = uppo.Ruleset.newGame(
            players: ["abc", "def"], seed: uppo.Seed("TTCT"));

        game.bundles["abc"]
            .transferCardByID(from: game.bundles["^deck"], id: 104);

        var approval = uppo.Ruleset.isPlayLegal(
            before: game,
            hand: game.bundles["abc"],
            playerAction: uppo.PlayerAction(
                cardId: game.bundles["abc"].getCards()[7].id,
                playerId: "abc"));

        expect(approval, equals(uppo.LegalResponse.Accepted));
      });
    });
  });
}
