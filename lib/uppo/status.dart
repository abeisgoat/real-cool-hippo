import 'package:uppo/player_metadata.dart';
import 'package:uppo/uppo/cards.dart';
import 'package:uppo/uppo/game_state.dart';

class Status {
  static const int TURN = 0;
  static const int MUST_DRAW = 1;
  static const int WILD_PICK = 2;
}

class StatusEntry {
  final int status;
  final String actor;
  final String uid;
  final Map<String, PlayerMetadata> players;
  Map<String, dynamic> bundle;

  StatusEntry(this.status, this.actor, this.uid, this.players, {this.bundle}) {
    if (this.bundle == null) this.bundle = {};
  }

  Map<String, dynamic> toMap() {
    return {"s": this.status, "a": this.actor, "b": this.bundle};
  }

  static StatusEntry fromGameStateSnapshot(
      GameStateSnapshot gss, Map<String, PlayerMetadata> players, String uid) {
    var sortedPlayers = players.keys.toList();
    sortedPlayers.sort();

    var cardsToDraw = 0;
    var wildPick = false;
    if (players[uid] != null && players[uid].hand != null) {
      players[uid].hand.getCards().forEach((card) {
        if (card is CommandCard) {
          if (card.command.startsWith("DrawRequired")) {
            cardsToDraw++;
          }

          if (card.command.startsWith("Wild_Pick")) {
            wildPick = true;
          }
        }
      });
    }

    if (wildPick) {
      return StatusEntry(Status.WILD_PICK, uid, uid, players);
    }

    if (cardsToDraw > 0) {
      return StatusEntry(Status.MUST_DRAW, uid, uid, players,
          bundle: {"count": cardsToDraw});
    }

    return StatusEntry(
        Status.TURN, sortedPlayers[gss.livePlayer], uid, players);
  }

  String toStringWithContext() {
    var actorMetadata = players.values.where((pm) => pm.id == this.actor).first;

    if (this.actor == uid) {
      switch (status) {
        case Status.TURN:
          return "It's your turn";
        case Status.MUST_DRAW:
          return "You must draw ${this.bundle["count"]} cards";
        case Status.WILD_PICK:
          return "Pick a color";
      }
    } else {
      switch (status) {
        case Status.TURN:
          return "It's ${actorMetadata.name}'s turn";
        case Status.MUST_DRAW:
          return "${actorMetadata.name} must draw ${this.bundle["count"]} cards";
        case Status.WILD_PICK:
          return "${actorMetadata.name} is picking a color";
      }
    }
  }
}
