import 'package:meta/meta.dart';
import 'dart:math' as math;
import 'cards.dart';
import 'master_deck.dart';

enum CardBundleOperationAction { Removed, Added }

class CardBundleOperation {
  final CardBundleOperationAction action;
  final int card;
  CardBundleOperation({this.card, this.action});

  toString() {
    return "$action -- $card";
  }

  @override
  bool operator ==(other) {
    if (other is CardBundleOperation) {
      return other.action == action && other.card == card;
    }

    return false;
  }
}

class CardBundle {
  final MasterDeck masterDeck;
  final List<int> _cards = [];
  final bool useReverseSerialization;

  CardBundle({@required this.masterDeck, this.useReverseSerialization = false});

  hasCardByID(int id) {
    return _cards.contains(id);
  }

  addCardByID(int id) {
    _cards.add(id);
  }

  addCardsByID(List<int> ids) {
    ids.forEach(this.addCardByID);
  }

  removeCardByID(int id, {quiet = false}) {
    if (!_cards.remove(id) && !quiet) {
      throw "Can't remove card $id, it's not in this CardBundle";
    }
  }

  removeCardsByID(List<int> ids, {quiet = false}) {
    ids.forEach((id) => this.removeCardByID(id, quiet: quiet));
  }

  transferCardByID({CardBundle from, int id}) {
    from.removeCardByID(id);
    addCardByID(id);
  }

  getRandomCardID(math.Random rng) {
    return _cards[rng.nextInt(_cards.length)];
  }

  Card getCardByCommand(String command) {
    return this
        ._cards
        .map((id) => masterDeck.getCardByID(id))
        .firstWhere((card) => card is CommandCard && card.command == command);
  }

  List<Card> getCardsByCommand(String command) {
    return this
        ._cards
        .map((id) => masterDeck.getCardByID(id))
        .where((card) => (card is CommandCard && card.command == command));
  }

  int cc(String command) {
    return this.getCardByCommand(command).id;
  }

  List<int> ccs(String command) {
    return this.getCardsByCommand(command).map((card) => card.id).toList();
  }

  List<Card> getCards() {
    this._cards.sort();
    return this._cards.map((id) {
      return masterDeck.getCardByID(id);
    }).toList();
  }

  List<CardBundleOperation> diff(CardBundle otherCardBundle) {
    var cardsRemoved =
        _cards.where((card) => !otherCardBundle._cards.contains(card)).toList();
    var cardsAdded =
        otherCardBundle._cards.where((card) => !_cards.contains(card)).toList();

    List<CardBundleOperation> ops = [];

    for (var card in cardsAdded) {
      ops.add(CardBundleOperation(
          card: card, action: CardBundleOperationAction.Added));
    }

    for (var card in cardsRemoved) {
      ops.add(CardBundleOperation(
          card: card, action: CardBundleOperationAction.Removed));
    }

    return ops;
  }

  String toString() {
    var cards = masterDeck.getCards(includeCommands: true);
    var maxId = cards.map((c) => c.id).reduce(math.max);
    var numGroups = (maxId >> 5) + 1;
    var groups = List.filled(numGroups, 0);

    for (var card in cards) {
      var group = card.id >> 5;

      var bit = card.id & 0x1f;
      var mask = 1 << bit;

      var cardPresent = _cards.contains(card.id);

      if ((!useReverseSerialization && cardPresent) ||
          (useReverseSerialization && !cardPresent)) {
        groups[group] |= mask;
      }
    }

    return (useReverseSerialization ? "-" : "+") + groups.join(".");
  }

  static CardBundle fromString({MasterDeck masterDeck, String string}) {
    var useReverseSerialization = string[0] == "-";
    var cb = CardBundle(
        masterDeck: masterDeck,
        useReverseSerialization: useReverseSerialization);

    var groups = string.substring(1).split(".").map(int.tryParse).toList();

    for (var card in masterDeck.getCards(includeCommands: true)) {
      var group = card.id >> 5;

      var bit = card.id & 0x1f;
      var mask = 1 << bit;

      var cardPresent = useReverseSerialization ? 0 : 1;

      var bitValue = ((groups[group] & mask) >> bit);
      if (bitValue == cardPresent) {
        cb._cards.add(card.id);
      }
    }

    return cb;
  }
}
