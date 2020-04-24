import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_html/prefer_sdk/html.dart' as html;
//import 'dart:html' if (dart.library.io) "./html_nonjs.dart" as html;

class Cursor extends MouseRegion {
  static final appContainer =
      html.window.document.getElementById('app-container');
  Cursor({Widget child})
      : super(
          onHover: (PointerHoverEvent evt) {
            appContainer.style.cursor = 'pointer';
          },
          onExit: (PointerExitEvent evt) {
            appContainer.style.cursor = 'default';
          },
          child: child,
        );
}
