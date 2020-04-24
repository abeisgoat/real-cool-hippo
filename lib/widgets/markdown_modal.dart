import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uppo/main.dart';
import 'package:uppo/widgets/animated_disappear.dart';
import 'package:uppo/widgets/modal_window.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownModal extends StatefulWidget {
  final String asset;
  final Modals modal;
  MarkdownModal({Key key, this.asset, this.modal}) : super(key: key);

  @override
  MarkdownModalState createState() {
    return MarkdownModalState();
  }
}

class MarkdownModalState extends State<MarkdownModal> {
  String data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  _fetch() async {
    data = await rootBundle.loadString(widget.asset);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ModalSingleton.active,
        builder: (ctx, value, _) {
          return AnimatedDisappear(
              duration: Duration(milliseconds: 250),
              curve: Curves.linear,
              visible: value == widget.modal,
              child: GestureDetector(
                  onTap: () {
                    ModalSingleton.active.value = Modals.None;
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                      ),
                      child: ModalWindow(
                        child: Markdown(
                          shrinkWrap: true,
                          onTapLink: (url) {
                            launch(url);
                          },
                          data: data != null ? data : "",
                          styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 26,
                              ),
                              h2: TextStyle(
                                decorationColor: Colors.black,
                                color: Colors.black54,
                                fontSize: 20,
                              )),
                        ),
                      ))));
        });
  }
}
