import 'package:flutter/cupertino.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/main.dart';
import 'package:uppo/server.dart';
import 'package:uppo/widgets/card.dart';
import '../uppo/uppo.dart' as uppo;

class PlayedArea extends StatefulWidget {
  PlayedArea({Key key}) : super(key: key);

  @override
  _PlayedArea createState() {
    return _PlayedArea();
  }
}

class OffsetNotification extends Notification {
  final Offset offset;
  const OffsetNotification({this.offset});
}

class _PlayedArea extends State<PlayedArea> {
  uppo.LegalResponse _isLegalCardPlay = uppo.LegalResponse.NoJudgement;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        padding: EdgeInsets.all(
            _isLegalCardPlay == uppo.LegalResponse.Accepted ? 10 : 0),
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceOut,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          border: Border.all(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              width: _isLegalCardPlay == uppo.LegalResponse.Accepted ? 2 : 0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: DragTarget(
          builder: (context, List<int> candidateData, rejectedData) {
            var renderBox = context.findRenderObject() as RenderBox;
            if (renderBox != null) {
              OffsetNotification(offset: renderBox.localToGlobal(Offset.zero))
                  .dispatch(context);
            }
            return ValueListenableBuilder(
                valueListenable: LobbySingleton.gss,
                builder: (ctx, gss, child) {
                  return AdvancedCardWidget(
                      scale: 0.75,
                      card: gss != null
                          ? MASTER_DECK.getCardByID(gss.liveCardId)
                          : null);
                });
          },
          onWillAccept: (data) {
            var legalResponse = uppo.Ruleset.isPlayLegal(
                before: LobbySingleton.gss.value,
                hand: LobbySingleton.hand.value,
                playerAction: uppo.PlayerAction(
                    cardId: data, playerId: LobbySingleton.uid.value));
            setState(() {
              _isLegalCardPlay = legalResponse;
            });

            return _isLegalCardPlay == uppo.LegalResponse.Accepted;
          },
          onLeave: (data) {
            setState(() {
              _isLegalCardPlay = uppo.LegalResponse.NoJudgement;
            });
          },
          onAccept: (cardId) {
            setState(() {
              _isLegalCardPlay = uppo.LegalResponse.NoJudgement;
            });
          },
        ),
      ),
    );
  }
}
