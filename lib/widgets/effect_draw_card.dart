import 'package:flutter/cupertino.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/effects.dart';
import 'package:uppo/uppo/card_bundle.dart';
import 'package:uppo/uppo/game_state.dart';
import 'package:uppo/widgets/animated_translate.dart';
import 'package:uppo/widgets/card.dart';
import '../main.dart';

class EffectDrawCard extends StatefulWidget {
  EffectRegistry<CardBundle> registry;

  EffectDrawCard({@required this.registry, Key key}) : super(key: key);

  @override
  _EffectDrawCard createState() {
    return _EffectDrawCard();
  }
}

enum PopupState { Up, Down, Pending }

class _EffectDrawCard extends State<EffectDrawCard>
    implements Effect<CardBundle> {
  int _drawnCard;
  PopupState _drawnCardState = PopupState.Down;

  @override
  void initState() {
    super.initState();
    widget.registry.effects["draw_card"] = this;
  }

  @override
  Future<void> performEffect(before, after) async {
    setState(() {
      _drawnCardState = PopupState.Up;
      _drawnCard = before.diff(after)[0].card;
    });

    await Future.delayed(Duration(milliseconds: 700));

    setState(() {
      _drawnCardState = PopupState.Down;
    });

    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTranslate(
        offset:
            _drawnCardState == PopupState.Up ? Offset(0, -30) : Offset(0, 190),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutCirc,
        child: AdvancedCardWidget(
          scale: 0.85,
          card: _drawnCard != null ? MASTER_DECK.getCardByID(_drawnCard) : null,
        ));
  }
}
