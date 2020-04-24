import 'dart:html' if (dart.library.io) "./html_nonjs.dart" as html;

class LocalStorage {
  final html.Storage _localStorage = html.window.localStorage;
  final String group;
  LocalStorage(this.group);

  void setItem(String key, dynamic value) {
    _localStorage["$group->$key"] = value;
  }

  String getItem(String key) {
    return _localStorage["$group->$key"];
  }

  removeItem(String key) {
    _localStorage.remove("$group->$key");
  }
}
