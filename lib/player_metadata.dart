import 'package:uppo/uppo/card_bundle.dart';
import 'package:uppo/uppo/cards.dart';

class PlayerMetadata {
  String id;
  String name;
  int count;
  bool ready;
  CardBundle hand;

  PlayerMetadata(
      {this.id, this.name, this.count, this.hand, this.ready = false});
}
