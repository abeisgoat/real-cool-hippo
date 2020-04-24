import 'package:flutter/cupertino.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/effects.dart';
import 'package:uppo/server.dart';
import 'package:uppo/uppo/card_bundle.dart';
import 'package:uppo/uppo/cards.dart';
import 'package:uppo/uppo/game_state.dart';
import 'package:uppo/uppo/master_deck.dart';
import 'package:uppo/widgets/animated_translate.dart';
import 'package:uppo/widgets/card.dart';
import 'package:uppo/widgets/controlled_animated_positioned.dart';
import '../main.dart';

class EffectPlayCardBundle {
  Offset offset;
  Card card;

  EffectPlayCardBundle({this.offset, this.card});
}

class EffectPlayCard extends StatefulWidget {
  EffectRegistry<EffectPlayCardBundle> registry;

  EffectPlayCard({@required this.registry, Key key}) : super(key: key);

  @override
  _EffectPlayCard createState() {
    return _EffectPlayCard();
  }
}

class _EffectPlayCard extends State<EffectPlayCard>
    implements Effect<EffectPlayCardBundle> {
  Card card;
  Offset start;
  Offset end;

  @override
  void initState() {
    super.initState();
    widget.registry.effects["play_card"] = this;
  }

  @override
  Future<void> performEffect(before, after) async {
    CardBundle hand = LobbySingleton.hand.value;
    String bundle = hand.toString();

    hand.removeCardByID(after.card.id);
    LobbySingleton.hand.notifyListeners();

    setState(() {
      start = before.offset;
      end = after.offset;
      card = after.card;
    });

    try {
      var resp = [
        await UppoServer.play(
            {"cid": after.card.id, "gid": LobbySingleton.gameId.value}),
        await Future.delayed(Duration(milliseconds: 700))
      ];
      bundle = resp[0].data["bundle"];
    } catch (err) {
      print("Server Error, fuck.");
    }

    LobbySingleton.hand.value = CardBundle.fromString(
        masterDeck: MASTER_DECK, string: bundle);

    await Future.delayed(Duration(milliseconds: 100));

    setState(() {
      card = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return card != null
        ? ControlledAnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            start: start,
            end: end,
            child: AdvancedCardWidget(card: card, angle: 0, scale: 0.75),
            disposeOnCompleted: true,
          )
        : Container();
  }
}
