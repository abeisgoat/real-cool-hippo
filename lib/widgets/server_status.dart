import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/server.dart';

class ServerStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: "Connection Status",
        child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: ValueListenableBuilder(
              valueListenable: UppoServer.hasPendingOperations,
              builder: (ctx, hasPendingOperations, child) {
                return AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    width: 20,
                    height: 20,
                    padding: hasPendingOperations
                        ? EdgeInsets.all(2)
                        : EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      border: Border.all(color: GREEN_BOLD, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: hasPendingOperations
                                ? GREEN_BOLD
                                : GREEN_PASTEL)));
              },
            )));
  }
}
