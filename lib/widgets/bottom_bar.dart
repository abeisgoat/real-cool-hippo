import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/cursor.dart';
import 'package:uppo/widgets/hoverable.dart';

class BottomBar extends StatelessWidget {
  static final height = 61.0;
  List<Widget> items;

  BottomBar({this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: UI_BAR_COLOR, boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3), spreadRadius: 1, blurRadius: 1)
      ]),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.where((w) => w != null).toList()),
    );
  }

  static Widget item(String text, IconData icon,
      {rounded = false, onTap: Function, onDisabledTap: Function, bool enabled = true}) {
    var disabled = Color.fromRGBO(255, 255, 255, 0.5);
    return Hoverable(
      builder: (ctx, hovered) {
        return Padding(
            padding: EdgeInsets.only(top: 5),
            child: GestureDetector(
                onTap: () {
                  if (enabled) {
                    onTap();
                  } else if (onDisabledTap != null) {
                    onDisabledTap();
                  }
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Cursor(
                        child: Container(
                      height: 59,
                      width: 90,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              icon,
                              color: enabled ? Colors.white : disabled,
                              size: 20.0,
                            ),
                            Text(text,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: enabled ? Colors.white : disabled,
                                ))
                          ]),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hovered && enabled
                            ? Color.fromRGBO(0, 0, 0, 0.8)
                            : Colors.black87,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(rounded ? 5 : 0),
                            bottomLeft: Radius.circular(rounded ? 5 : 0)),
                      ),
                    )))));
      },
    );
  }
}
