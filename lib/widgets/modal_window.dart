import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWindow extends StatelessWidget {
  final Widget child;

  ModalWindow({this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 100, horizontal: 20),
            child: Container(
                width: 400,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      spreadRadius: 1,
                      blurRadius: 1)
                ], color: Colors.white, borderRadius: BorderRadius.circular(5)),
                child: child)));
  }
}
