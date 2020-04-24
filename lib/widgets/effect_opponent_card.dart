import 'package:flutter/cupertino.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/effects.dart';
import 'package:uppo/uppo/card_bundle.dart';
import 'package:uppo/uppo/cards.dart';
import 'package:uppo/uppo/game_state.dart';
import 'package:uppo/widgets/animated_translate.dart';
import 'package:uppo/widgets/card.dart';
import 'package:uppo/widgets/opponent_hand.dart';
import '../main.dart';

class EffectOpponentCard extends StatefulWidget {
  EffectRegistry<GameStateSnapshot> registry;
  String id;
  SpreadDirection direction;
  Alignment alignment;

  EffectOpponentCard(
      {@required this.registry,
      Key key,
      this.id,
      @required this.direction,
      @required this.alignment})
      : super(key: key);

  @override
  _EffectOpponentCard createState() {
    return _EffectOpponentCard();
  }
}

enum PopupState { Up, Down, Pending }

class _EffectOpponentCard extends State<EffectOpponentCard>
    implements Effect<GameStateSnapshot> {
  Alignment alignment;
  Card card;

  @override
  void initState() {
    super.initState();
    widget.registry.effects[widget.id.toString()] = this;
  }

  @override
  Future<void> performEffect(before, after) async {
    setState(() {
      card = MASTER_DECK.getCardByID(after.liveCardId);
    });

    await Future.delayed(Duration(milliseconds: 700));

    LobbySingleton.gss.value = after;

    setState(() {
      card = null;
    });

    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    var hiddenOffset = Offset(
        widget.direction == SpreadDirection.Left
            ? -AdvancedCardWidget.width
            : AdvancedCardWidget.width,
        0);

    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutSine,
        alignment: card != null ? Alignment.center : widget.alignment,
        child: AnimatedTranslate(
            curve: Curves.easeInOutSine,
            duration: Duration(milliseconds: 500),
            offset: card != null ? Offset(0, -31) : hiddenOffset,
            child: card != null
                ? AdvancedCardWidget(scale: 0.75, card: card)
                : Text("")));
  }
}
