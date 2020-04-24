import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:uppo/main.dart';
import './uppo/uppo.dart' as uppo;

typedef HttpsCallableWithStatus = Future<HttpsCallableResult> Function(
    [dynamic parameters]);

HttpsCallableWithStatus getHttpsCallableWithStatus({String functionName}) {
  final httpsCallable =
      CloudFunctions.instance.getHttpsCallable(functionName: functionName);
  return ([dynamic parameters]) async {
    if (UppoServer.hasPendingOperations.value) {
      throw "Can't '$functionName', already have pending operations.";
    }

    UppoServer.hasPendingOperations.value = true;
    HttpsCallableResult resp = await httpsCallable(parameters);
    UppoServer.hasPendingOperations.value = false;


    return resp;
  };
}

class UppoServer {
  static ValueNotifier hasPendingOperations = ValueNotifier(false);

  static final play = getHttpsCallableWithStatus(
    functionName: 'play',
  );

  static final start = getHttpsCallableWithStatus(
    functionName: 'startGame',
  );

  static final join = getHttpsCallableWithStatus(
    functionName: 'joinGame',
  );

  static final ready = getHttpsCallableWithStatus(
    functionName: 'ready',
  );

  static void applyPlay(int id) async {
    uppo.CardBundle hand = LobbySingleton.hand.value;
    String bundle = hand.toString();

    hand.removeCardByID(id);
    LobbySingleton.hand.notifyListeners();

    try {
      var resp = [
        await UppoServer.play({"cid": id, "gid": LobbySingleton.gameId.value}),
        await Future.delayed(Duration(milliseconds: 700))
      ];
      bundle = resp[0].data["bundle"];
    } catch (err) {
      print("Server Error, fuck.");
    }

    LobbySingleton.hand.value = uppo.CardBundle.fromString(
        masterDeck: LobbySingleton.gss.value.masterDeck, string: bundle);
    LobbySingleton.hand.notifyListeners();
  }
}
