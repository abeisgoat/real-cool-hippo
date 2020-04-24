import 'dart:convert';
import 'package:uppo/uppo/cards.dart';

import "master_deck.dart";
import 'card_bundle.dart';

T cast<T>(x) => x is T ? x : null;

class CardMovement {
  String from;
  String to;

  CardMovement({this.from, this.to});

  @override
  String toString() {
    return "$from -> $to";
  }

  @override
  bool operator ==(other) {
    return other.to == to && other.from == from;
  }
}

class GameStateSnapshot {
  int liveCardId;
  int livePlayer;
  int turnsPlayed;
  MasterDeck masterDeck;
  Map<String, int> score;

  Map<String, dynamic> temporary = {};
  Map<String, CardBundle> bundles = {};

  CardBundle getPlayerBundle(String playerId) {
    return bundles[playerId];
  }

  CardBundle getPlayerBundleByIndex(int playerId) {
    var bundleKeys = bundles.keys.where((key) => !key.startsWith("^")).toList();
    bundleKeys.sort();
    return bundles[bundleKeys[playerId]];
  }

  int getPlayerCount() {
    return bundles.keys.where((key) => !key.startsWith("^")).length;
  }

  diff(GameStateSnapshot otherGameStateSnapshot) {
    Map<int, CardMovement> movements = {};

    for (var cbKey in bundles.keys) {
      for (var op
          in otherGameStateSnapshot.bundles[cbKey].diff(bundles[cbKey])) {
        var movement = CardMovement();

        if (movements.containsKey(op.card)) {
          movement = movements[op.card];
        }

        if (op.action == CardBundleOperationAction.Added) {
          movement.to = cbKey;
        }

        if (op.action == CardBundleOperationAction.Removed) {
          movement.from = cbKey;
        }

        movements[op.card] = movement;
      }
    }

    return movements;
  }

  toMap() {
    Map<String, String> stringifiedBundles = {};
    Map<String, int> bundleCounts = {};

    var direction = 0;
    for (var key in bundles.keys) {
      bundleCounts[key] = bundles[key]
          .getCards()
          .where((card) => !(card is CommandCard))
          .length;

      if (bundles[key].hasCardByID(masterDeck.cc("Turn++"))) {
        direction = 1;
      }
      if (bundles[key].hasCardByID(masterDeck.cc("Turn--"))) {
        direction = -1;
      }

      stringifiedBundles[key] = bundles[key].toString();
    }

    var map = {
      "b": stringifiedBundles,
      "l": liveCardId,
      "a": livePlayer,
      "t": turnsPlayed,
      "_d": direction,
      "_c": bundleCounts,
    };

    if (score != null) {
      map["_f"] = score;
    }
    return map;
  }

  GameStateSnapshot clone() {
    return GameStateSnapshot.fromMap(
        map: this.toMap(), masterDeck: this.masterDeck);
  }

  static GameStateSnapshot fromMap(
      {Map<String, dynamic> map, MasterDeck masterDeck}) {
    var gss = GameStateSnapshot();
    gss.masterDeck = masterDeck;
    gss.liveCardId = map["l"];
    gss.livePlayer = map["a"];
    gss.turnsPlayed = map["t"];

    map.entries.where((pair) => pair.key.startsWith("_")).forEach((pair) {
      gss.temporary[pair.key] = pair.value;
    });

    var bundles = cast<Map<dynamic, dynamic>>(map["b"]);

    for (var key in bundles.keys) {
      gss.bundles[key] =
          CardBundle.fromString(masterDeck: masterDeck, string: bundles[key]);
    }

    return gss;
  }

  static GameStateSnapshot fromString({String string, MasterDeck masterDeck}) {
    return GameStateSnapshot.fromMap(
        map: jsonDecode(string), masterDeck: masterDeck);
  }

  toString() {
    return jsonEncode(toMap());
  }
}
