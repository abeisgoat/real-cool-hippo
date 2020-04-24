import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/widgets/animated_disappear.dart';

class Modal extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Function onBackgroundTap;

  Modal({this.child, this.visible, this.onBackgroundTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedDisappear(
        duration: Duration(milliseconds: 250),
        curve: Curves.linear,
        visible: visible,
        child: GestureDetector(
            onTap: () {
              if (onBackgroundTap != null) onBackgroundTap();
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                ),
                child: child)));
  }
}
