import 'package:meta/meta.dart';

enum CardColor { Red, Blue, Green, Yellow }
enum CardAction {
  Skip,
  Reverse,
  DrawTwo,
}
enum WildCardAction { DrawNone, DrawFour }

abstract class Card implements Comparable {
  final int id;
  final CardColor color;
  Card({this.color, this.id});

  String toString();

  @override
  bool operator ==(other) {
    if (other is Card) {
      return this.id == other.id;
    }

    return false;
  }

  @override
  int compareTo(other) {
    return other.card - id;
  }
}

class ActionCard extends Card {
  final CardAction action;
  ActionCard(
      {@required CardColor color, @required this.action, @required int id})
      : super(color: color, id: id);

  @override
  String toString() {
    return '$color:$action';
  }
}

class NumberCard extends Card {
  final int number;
  NumberCard(
      {@required CardColor color, @required this.number, @required int id})
      : super(color: color, id: id);

  @override
  String toString() {
    return '$color:$number';
  }
}

class WildCard extends Card {
  final WildCardAction action;
  WildCard({@required this.action, @required int id}) : super(id: id);

  @override
  String toString() {
    return '$action';
  }
}

class CommandCard extends Card {
  final String command;
  CommandCard({
    @required this.command,
    @required int id,
    CardColor color,
  }) : super(id: id, color: color);

  @override
  String toString() {
    return 'Command:$command';
  }
}
