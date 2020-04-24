import 'package:flutter/cupertino.dart';
import 'package:uppo/utils.dart';

class Effect<T> {
  Future<void> performEffect(T before, T after) {
    throw UnimplementedError();
  }
}

class EffectRegistry<T> {
  final Map<String, Effect<T>> effects = {};
  bool lockedForEffects = false;
  bool lockedManually = false;
  final lockNotifier = ValueNotifier(false);

  get locked {
    return lockNotifier.value;
  }

  Future<void> wait() {
    return waitForValueNotifier(lockNotifier, false);
  }

  void lock() {
    lockedManually = true;
    notify();
  }

  void unlock() {
    lockedManually = false;
    notify();
  }

  Future<void> performEffects(T before, T after) async {
    lockedForEffects = true;
    notify();
    await Future.wait(
        effects.values.map((effect) => effect.performEffect(before, after)));
    lockedForEffects = false;
    notify();
  }

  notify() {
    lockNotifier.value = lockedForEffects || lockedManually;
  }
}
