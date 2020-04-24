import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/main.dart';
import 'package:uppo/player_metadata.dart';
import 'package:uppo/uppo/game_state.dart';
import 'package:uppo/uppo/status.dart';
import 'package:uppo/widgets/server_status.dart';

class Topbar extends StatelessWidget {
  Topbar();

  List<Widget> nextPlayerTurns(
      GameStateSnapshot gss, String uid, Map<String, PlayerMetadata> players) {
    List<Widget> order = [];
    if (players == null || gss == null) return order;

    var start = gss.livePlayer;
    var sortedPlayerIDs = players.keys.toList();
    sortedPlayerIDs.sort();

    for (var i = 0; i < 3; i++) {
      var index = start + (gss.temporary["_d"] * i);

      index %= sortedPlayerIDs.length;
      var pm = players[sortedPlayerIDs[index]];
      if (pm != null) {
        order.add(Text(
          pm.name,
          style: TextStyle(
              fontWeight: pm.id == uid ? FontWeight.bold : FontWeight.normal),
        ));
        order.add(Icon(Icons.navigate_next, color: Colors.black26));
      }
    }

    if (order.length > 1) {
      return order.sublist(0, order.length - 1);
    } else {
      return [];
    }
  }

  Widget bubble(child) {
    return Container(
      child: child,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2), spreadRadius: 1, blurRadius: 1)
      ], color: UI_BAR_COLOR, borderRadius: BorderRadius.circular(5)),
    );
  }

  String getStatus(
      GameStateSnapshot gss, String uid, Map<String, PlayerMetadata> players) {
    var status = "...";

    if (gss != null && uid != null && players.length > 0) {
      status = StatusEntry.fromGameStateSnapshot(gss, players, uid)
          .toStringWithContext();
    }

    return status;
  }

  String getTurnsRemaining(GameStateSnapshot gss) {
    if (gss != null) {
      return (max(100 - gss.turnsPlayed, 0)).toString();
    }

    return "~";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LobbySingleton.gss,
      builder: (ctx, gss, child) {
        var turnsRemaining = getTurnsRemaining(gss);
        return Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 1000),
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                        offset: Offset(0, 20),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Tooltip(
                                  message: "Next player turns",
                                  child: bubble(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: nextPlayerTurns(
                                          gss,
                                          LobbySingleton.uid.value,
                                          LobbySingleton.players.value)))),
                              Container(width: 5, height: 0),
                              Tooltip(
                                  message: "${turnsRemaining} turns remain",
                                  child: bubble(Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(Icons.rotate_90_degrees_ccw,
                                              size: 20,
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 0.25)),
                                          Text(" $turnsRemaining")
                                        ],
                                      )))),
                            ]))),
                Align(alignment: Alignment.centerRight, child: ServerStatus()),
                Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                        offset: Offset(0, -7),
                        child: ValueListenableBuilder(
                          valueListenable: LobbySingleton.hand,
                          builder: (ctx, hand, child) {
                            if (LobbySingleton
                                    .players.value[LobbySingleton.uid.value] !=
                                null) {
                              LobbySingleton.players
                                  .value[LobbySingleton.uid.value].hand = hand;
                            }
                            return Text(
                                getStatus(gss, LobbySingleton.uid.value,
                                    LobbySingleton.players.value),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold));
                          },
                        ))),
              ],
            ),
            height: 70,
            decoration: BoxDecoration(
              color: UI_BAR_COLOR,
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                  bottomRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0)),
            ));
      },
    );
  }
}
