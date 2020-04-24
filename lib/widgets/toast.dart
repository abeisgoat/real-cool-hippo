import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/widgets/animated_disappear.dart';

class ToastSingleton {
  static ValueNotifier visibleNotifier = ValueNotifier<bool>(false);
  static String text = "";
  static show(String message) async {
    if (visibleNotifier.value != false) return;

    text = message;
    visibleNotifier.value = true;
    await Future.delayed(Duration(milliseconds: 1500));
    visibleNotifier.value = false;
  }
}

class Toast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ToastSingleton.visibleNotifier,
      builder: (ctx, visible, child) {
        return AnimatedDisappear(
            curve: Curves.linear,
            duration: Duration(milliseconds: 200),
            visible: visible,
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Text(ToastSingleton.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white, fontSize: 20))))));
      },
    );
  }
}
