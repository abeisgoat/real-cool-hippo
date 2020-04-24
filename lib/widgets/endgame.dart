import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/main.dart';
import 'package:uppo/player_metadata.dart';
import 'package:uppo/uppo/game_state.dart';
import 'package:uppo/widgets/animated_disappear.dart';
import 'package:uppo/widgets/crummy_button.dart';
import 'package:uppo/widgets/modal.dart';
import 'package:uppo/widgets/modal_window.dart';

class EndGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameStateSnapshot>(
      valueListenable: LobbySingleton.gss,
      builder: (ctx, gss, child) {
        Map<String, dynamic> scores;

        if (gss != null) {
          scores = gss.temporary["_f"];
        }
        if (scores == null) scores = {};

        Map<String, PlayerMetadata> players = LobbySingleton.players.value;


        const scorePositions = ["1st", "2nd", "3rd", "4th", "5th"];
        List<Widget> scoreWidgets = [];
        var index = 0;
        var sortedScores = scores.entries.toList();
        sortedScores.sort((a, b) => b.value - a.value);

        sortedScores.forEach((pair) {
          if (index == 0) {
            scoreWidgets.add(Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text("${players[pair.key].name} won!",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold))));
          } else {
            scoreWidgets.add(Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                    "${scorePositions[index]} - ${players[pair.key].name}",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.normal))));
          }

          scoreWidgets.add(Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("${pair.value} league points",
                  style: TextStyle(fontSize: 14, color: Colors.black54))));
          index++;
        });

        scoreWidgets.add(Container(height: 10));
        scoreWidgets.add(CrummyButton(
          text: "Leave Game",
          lightmode: true,
          onTap: () {
            QuitNotification().dispatch(ctx);
          },
        ));

        return Modal(
            visible: scores.length > 0,
            child: ModalWindow(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: scoreWidgets,
                    ))));
      },
    );
  }
}
