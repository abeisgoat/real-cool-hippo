import 'package:flutter/material.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/main.dart';
import 'dart:math' as math;

import 'card.dart';
import '../uppo/uppo.dart' as uppo;

class PlayerHand extends StatelessWidget {
  final ValueNotifier<uppo.CardBundle> handListener;

  PlayerHand({@required this.handListener});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ValueListenableBuilder<uppo.CardBundle>(
        valueListenable: handListener,
        builder: (ctx, hand, child) {
          if (hand == null) return Container();

          List<uppo.Card> playableCards = [];
          List<uppo.Card> commandCards = [];

          hand.getCards().forEach((card) {
            if (card is uppo.CommandCard) {
              commandCards.add(card);
            } else {
              playableCards.add(card);
            }
          });

          var cardWidth = BasicCardWidget.width;
          var xStep, cardsWidth;

          xStep = math.min(cardWidth,
              (constraints.maxWidth - cardWidth) / (playableCards.length - 1));
          xStep = math.max<double>(36.0, xStep);
          cardsWidth = (xStep * (playableCards.length - 1)) + cardWidth;

          var half = (constraints.maxWidth - cardsWidth) / 2;

          if (half < 0) half = 0;

          List<Widget> cardWidgets = [];
          int index = 0;
          for (var card in playableCards) {
            var cardWidget = DraggableCardWidget(card: card);

            cardWidgets.add(AnimatedPositioned(
                key: Key(card.id.toString()),
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                left: half + (index * xStep),
                top: 0,
                child: cardWidget));
            index++;
          }
          return Container(
              child: Stack(children: [
            Positioned(
                top: 80,
                left: 10,
                right: 10,
                bottom: -3,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        border: Border.all(
                            color: Color.fromRGBO(0, 0, 0, 0.2), width: 2),
                        color: UI_BAR_COLOR))),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                    child: Stack(children: cardWidgets),
                    width: math.max(cardsWidth, constraints.maxWidth),
                    height: 100))
          ]));
        },
      );
    });
  }
}
