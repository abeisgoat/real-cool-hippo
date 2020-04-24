import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:uppo/player_metadata.dart';

Future<void> waitForValueNotifier<T>(ValueNotifier<T> notifier, T value,
    {String id}) async {
  if (notifier.value == value) {
    if (id != null) print("$id ${notifier.value}");
    return;
  }

  var completer = Completer<void>();
  var listener;
  listener = () {
    if (id != null) print("$id ${notifier.value}");
    if (notifier.value != value) return;

    notifier.removeListener(listener);
    completer.complete();
  };

  notifier.addListener(listener);

  return completer.future;
}

String getPlayerIDByIndex(Map<String, PlayerMetadata> players, int index) {
  var sortedKeys = players.keys.toList();
  sortedKeys.sort();
  return sortedKeys[index];
}
