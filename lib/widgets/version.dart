import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';

class Version extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: rootBundle.loadString("pubspec.yaml"),
        builder: (ctx, pubspec) {
          var text = "...";
          if (pubspec.hasData) {
            var yaml = loadYaml(pubspec.data);
            text = yaml["version"];
          }
          ;

          return Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: Colors.black38),
              ));
        });
  }
}
