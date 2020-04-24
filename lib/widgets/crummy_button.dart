import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/widgets/hoverable.dart';

class CrummyButton extends StatelessWidget {
  String text;
  Function onTap;
  Function onDisabledTap;
  Key key;
  Widget child;
  bool enabled;
  bool lightmode;

  CrummyButton(
      {this.text,
      this.onTap,
      this.key,
      this.child,
        this.onDisabledTap,
      this.enabled = true,
      this.lightmode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      child = Text(text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.black : Color.fromRGBO(0, 0, 0, 0.4)));
    }

    var THEME_COLOR = lightmode ? Color.fromRGBO(227, 227, 227, 1) : HIPPO_GREY;
    var THEME_HOVER_COLOR = lightmode
        ? Color.fromRGBO(207, 207, 207, 1)
        : Color.fromRGBO(147, 152, 149, 1);

    return Hoverable(
      builder: (ctx, hovered) {
        return GestureDetector(
            key: key,
            onTap: () {
              if (!enabled) {
                if (onDisabledTap != null) {
                  onDisabledTap();
                }
              } else {
                onTap();
              }
            },
            child: Container(
                height: 37,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:
                        hovered && enabled ? THEME_HOVER_COLOR : THEME_COLOR),
                child: Center(child: child)));
      },
    );
  }
}
