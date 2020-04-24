import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uppo/main.dart';
import 'package:uppo/widgets/animated_disappear.dart';
import 'package:uppo/widgets/crummy_button.dart';
import 'package:uppo/widgets/modal.dart';
import 'package:uppo/widgets/modal_window.dart';


class ConfirmBundle {
  String message;
  Function onConfirm;
  Function onCancel;
  String confirmText;
  String cancelText;
  ConfirmBundle({this.cancelText="Cancel", this.confirmText="Confirm", this.onConfirm, this.onCancel, this.message});
}

class ConfirmSingleton {
  static ValueNotifier visibleNotifier = ValueNotifier<bool>(false);
  static ConfirmBundle confirmBundle = ConfirmBundle(message: "");

  static show(ConfirmBundle confirmBundle) async {
    ConfirmSingleton.confirmBundle = confirmBundle;

    visibleNotifier.value = true;
  }

  static hide() {
    visibleNotifier.value = false;
  }
}

class Confirm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var onBackgroundTapOrCancel = () {
      var onCancel = ConfirmSingleton.confirmBundle.onCancel;
      if (onCancel == null) ConfirmSingleton.hide();
      else onCancel();
    };

    return ValueListenableBuilder(
      valueListenable: ConfirmSingleton.visibleNotifier,
      builder: (ctx, visible, child) {
        return Modal(
            visible: visible,
            onBackgroundTap: onBackgroundTapOrCancel,
            child: ModalWindow(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ConfirmSingleton.confirmBundle.message, textAlign: TextAlign.center, style: TextStyle(
                          fontSize: 20,
                          height: 1.2,
                          fontWeight: FontWeight.bold
                        )),
                        Container(height: 20),
                        Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                          CrummyButton(
                            text: ConfirmSingleton.confirmBundle.cancelText,
                            lightmode: true,
                            onTap: onBackgroundTapOrCancel,
                          ),
                          CrummyButton(
                            text: ConfirmSingleton.confirmBundle.confirmText,
                            lightmode: true,
                            onTap: () {
                              ConfirmSingleton.confirmBundle.onConfirm();
                              ConfirmSingleton.hide();
                            },
                          ),
                        ],)
                      ],
                    ))));
      },
    );
  }
}
