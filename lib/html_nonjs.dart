// This file is imported when running headless tests
import 'dart:collection';

class Storage extends MapMixin<String, String> {
  Storage() : super();

  Map<String, String> _store = {};

  @override
  String operator [](Object key) {
    return _store[key];
  }

  @override
  void operator []=(Object key, String value) {
    // TODO: implement []=
  }

  @override
  void clear() {
    _store.clear();
  }

  @override
  // TODO: implement keys
  Iterable<String> get keys => _store.keys;

  @override
  String remove(Object key) {
    _store.remove(key);
  }
}

class window {
  static Storage localStorage = Storage();
}
