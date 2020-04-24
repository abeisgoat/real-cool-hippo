import 'package:flutter/cupertino.dart';
import 'package:universal_html/prefer_sdk/html.dart' as html;

typedef HoverableWidgetBuilder = Widget Function(
    BuildContext context, bool hovered);

class Hoverable extends StatefulWidget {
  final HoverableWidgetBuilder builder;

  Hoverable({Key key, this.builder}) : super(key: key);

  @override
  _Hoverable createState() {
    return _Hoverable();
  }
}

class _Hoverable extends State<Hoverable> {
  bool hovered = false;
  static final appContainer =
      html.window.document.getElementById('app-container');

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: widget.builder(context, hovered),
      onEnter: (event) {
        setState(() {
          hovered = true;
          appContainer.style.cursor = 'pointer';
        });
      },
      onExit: (event) {
        setState(() {
          hovered = false;
          appContainer.style.cursor = 'default';
        });
      },
    );
  }
}
