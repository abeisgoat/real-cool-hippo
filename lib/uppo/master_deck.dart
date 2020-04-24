import 'cards.dart';

class MasterDeck {
  List<Card> _cards;

  MasterDeck({List<Card> cards}) {
    this._cards = cards;
  }

  Card getCardByID(int id) {
    return this._cards[id];
  }

  Card getCardByCommand(String command) {
    return this
        ._cards
        .firstWhere((card) => (card is CommandCard && card.command == command));
  }

  List<Card> getCardsByCommand(String command) {
    return this
        ._cards
        .where((card) => (card is CommandCard && card.command == command))
        .toList();
  }

  int cc(String command) {
    return this.getCardByCommand(command).id;
  }

  List<int> ccs(String command) {
    return this.getCardsByCommand(command).map((card) => card.id).toList();
  }

  List<Card> getCards({bool includeCommands = false}) {
    return this
        ._cards
        .where((card) => includeCommands || !(card is CommandCard))
        .toList();
  }
}
