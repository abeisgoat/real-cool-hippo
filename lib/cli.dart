import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import './uppo/uppo.dart' as uppo;

ArgResults argResults;

void commandPlay({String before, uppo.PlayerAction playerAction}) {
  var masterDeck = uppo.Ruleset.newMasterDeck();
  var beforeGSS =
      uppo.GameStateSnapshot.fromString(string: before, masterDeck: masterDeck);
  var afterGSS =
      uppo.Ruleset.play(before: beforeGSS, playerAction: playerAction);
  print(afterGSS.toString());
}

void commandNew({List<String> players, String seed}) {
  var gss = uppo.Ruleset.newGame(
      players: players, seed: uppo.Seed(seed.toUpperCase()));
  print(gss.toString());
}

void commandBundle({String bundle}) {
  var cb = uppo.CardBundle.fromString(
      masterDeck: uppo.Ruleset.newMasterDeck(), string: bundle);

  for (var card in cb.getCards()) {
    print("$card : ${card.id}");
  }
}

void commandCard({int cardId}) {
  var masterDeck = uppo.Ruleset.newMasterDeck();
  print(masterDeck.getCardByID(cardId));
}

void main(List<String> arguments) {
  exitCode = 0;
  final newParser = ArgParser()
    ..addMultiOption("players", abbr: "o")
    ..addOption("seed", abbr: "s");

  final playParser = ArgParser()
    ..addOption("before", abbr: "b")
    ..addOption("player", abbr: "p")
    ..addOption("card", abbr: "c");
  final sortParser = ArgParser()..addMultiOption("players", abbr: "o");

  final bundleParser = ArgParser()..addOption("bundle", abbr: "b");
  final cardParser = ArgParser()..addOption("card", abbr: "c");

  final parser = ArgParser()
    ..addCommand("new", newParser)
    ..addCommand("play", playParser)
    ..addCommand("sort", sortParser)
    ..addCommand("bundle", bundleParser)
    ..addCommand("card", cardParser);

  final result = parser.parse(arguments);
  switch (result.command.name) {
    case "new":
      commandNew(
          players: result.command["players"] as List<String>,
          seed: result.command["seed"]);
      break;
    case "bundle":
      commandBundle(bundle: result.command["bundle"]);
      break;
    case "card":
      commandCard(cardId: int.parse(result.command["card"]));
      break;
    case "sort":
      var ids = result.command["players"] as List<String>;
      ids.sort();
      print(jsonEncode(ids));
      break;
    case "play":
      commandPlay(
          before: result.command["before"],
          playerAction: uppo.PlayerAction(
              playerId: result.command["player"],
              cardId: int.parse(result.command["card"])));
      break;
  }
}
