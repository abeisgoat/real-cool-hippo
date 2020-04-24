import 'package:flutter/material.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/main.dart';
import 'package:uppo/player_metadata.dart';
import './card.dart';
import 'dart:math' as math;

enum SpreadDirection { Left, Right }

class OpponentHand extends StatelessWidget {
  final PlayerMetadata player;
  final SpreadDirection spreadDirection;
  OpponentHand({@required this.player, @required this.spreadDirection});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, PlayerMetadata>>(
      valueListenable: LobbySingleton.players,
      builder: (ctx, players, child) {
//        var cardDisplay = Transform.rotate(
//            angle: math.pi * .5,
//            child: Container(
//                padding: EdgeInsets.all(10),
//                decoration: BoxDecoration(
//                  color: Colors.white,
//                  borderRadius: BorderRadius.circular(10),
//                  boxShadow: [
//                    BoxShadow(
//                        color: Color.fromRGBO(0, 0, 0, 0.2),
//                        spreadRadius: 1,
//                        blurRadius: 1)
//                  ],
//                ),
//                child: Transform.rotate(
//                    angle: math.pi * 0.01,
//                    child: AdvancedCardWidget(scale: 0.5))));

        var cardCountDisplay = Container(
          child: Text("x${player.count}",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          padding: EdgeInsets.only(left: 19, right: 19, top: 20, bottom: 10),
          decoration: BoxDecoration(
              color: Color.fromRGBO(60, 60, 60, 1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(60, 60, 60, 0.2),
                    spreadRadius: 1,
                    blurRadius: 1)
              ]),
        );

        var nameDisplay = Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(player.name,
              style: TextStyle(color: Colors.white, fontSize: 20)),
          decoration: BoxDecoration(
              color: Color.fromRGBO(40, 40, 40, 1),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(40, 40, 40, 0.2),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: spreadDirection == SpreadDirection.Left
                  ? BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))
                  : BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
        );

//        var card = spreadDirection == SpreadDirection.Left
//            ? Positioned(left: -60, top: 24, child: cardDisplay)
//            : Positioned(right: -60, top: 24, child: cardDisplay);

        var name = spreadDirection == SpreadDirection.Left
            ? Positioned(
                left: 0,
                top: 10,
                child: nameDisplay,
              )
            : Positioned(
                right: 0,
                top: 10,
                child: nameDisplay,
              );

        var cardCount = spreadDirection == SpreadDirection.Left
            ? Positioned(left: -6, top: 40, child: cardCountDisplay)
            : Positioned(right: -6, top: 40, child: cardCountDisplay);

        return Tooltip(
            message: '${player.name} has ${player.count} cards',
            verticalOffset: -70,
            child: Container(
                height: 200,
                width: 150,
                child: Stack(children: [cardCount, name])));
      },
    );
  }
}
