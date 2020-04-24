import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:uppo/constants.dart';
import 'package:uppo/main.dart';
import 'package:uppo/widgets/controlled_animated_positioned.dart';

import '../uppo/uppo.dart' as uppo;

class BasicCardWidget extends StatelessWidget {
  final String value;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final double angle;

  static double width = 100.0;
  static double height = 140.0;

  BasicCardWidget(
      {@required this.value,
      @required this.borderColor,
      @required this.backgroundColor,
      @required this.textColor,
      this.angle = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              value,
              style: TextStyle(
                  color: this.textColor,
                  fontSize: 22.0,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: this.backgroundColor,
              border: Border.all(
                  color: this.borderColor, style: BorderStyle.solid, width: 2)),
        ));
  }
}

class CardBorder extends StatelessWidget {
  final Widget child;
  final double scale;
  final double width;
  final double height;
  final bool floating;

  CardBorder(
      {this.width,
      this.height,
      this.child,
      this.scale = 1.0,
      this.floating = false});

  @override
  Widget build(BuildContext context) {
    var grey = (255 * .3).round();
    return Stack(children: [
      Container(
        child: this.child,
        width: this.width,
        height: this.height,
        padding: EdgeInsets.all(6 * scale),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10 * scale),
            boxShadow: this.floating
                ? [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(2, 2))
                  ]
                : [],
            border: Border.all(
                color: Color.fromRGBO(grey, grey, grey, 1),
                style: BorderStyle.solid,
                width: 1)),
      ),
      Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Padding(
              padding: EdgeInsets.all(6 * scale),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(
                        color: Color.fromRGBO(0, 0, 0, 0.5), width: 3 * scale)),
              )))
    ]);
  }
}

class AdvancedCardWidget extends StatelessWidget {
  final uppo.Card card;
  final double angle;
  final double scale;
  final bool floating;
  String text;
  Color faceColor;
  Widget faceArt;
  List<Widget> faceTexts = [];
  static final width = 200.0;
  static final height = 280.0;

  AdvancedCardWidget(
      {this.card, this.angle = 0, this.scale = 0.5, this.floating = false}) {
    if (card == null) {
      text = "REAL COOL HIPPO";
      faceTexts = [
        Center(
            child: Text(text,
                style: TextStyle(
                  fontSize: 20 * scale,
                )))
      ];
      faceArt = Text("");
      faceColor = Colors.black12;
      return;
    }
    if (card is uppo.NumberCard) {
      text = (card as uppo.NumberCard).number.toString();
      faceTexts = [
        Positioned(
            top: 0 * scale,
            left: -24 * scale,
            right: 0,
            child: Text(text,
                textAlign: TextAlign.center,
                style: google_fonts.GoogleFonts.kalam(
                    textStyle: TextStyle(
                        height: 1,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 400 * scale,
                        color: Color.fromRGBO(0, 0, 0, 0.1))))),
        Positioned(
            top: 16 * scale,
            left: 16 * scale,
            child: Text(text,
                style: google_fonts.GoogleFonts.kalam(
                    textStyle: TextStyle(
                        height: 1,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 80 * scale,
                        color: Color.fromRGBO(0, 0, 0, 0.6)))))
      ];
    } else if (card is uppo.ActionCard) {
      switch ((card as uppo.ActionCard).action) {
        case uppo.CardAction.DrawTwo:
          text = "Draw +2";
          break;
        case uppo.CardAction.Reverse:
          text = "Reverse";
          break;
        case uppo.CardAction.Skip:
          text = "Skip";
          break;
      }

      faceTexts = [
        Positioned(
            top: 0 * scale,
            left: -24 * scale,
            right: 0,
            child: Text(text.substring(0, 1),
                textAlign: TextAlign.center,
                style: google_fonts.GoogleFonts.kalam(
                    textStyle: TextStyle(
                        height: 1,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 400 * scale,
                        color: Color.fromRGBO(0, 0, 0, 0.1))))),
        Positioned(
            top: 25 * scale,
            left: 0,
            right: 0,
            child: Text(text,
                textAlign: TextAlign.center,
                style: google_fonts.GoogleFonts.kalam(
                    textStyle: TextStyle(
                        height: 1,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 44 * scale,
                        color: Color.fromRGBO(0, 0, 0, 0.6)))))
      ];
    } else if (card is uppo.WildCard) {
      switch ((card as uppo.WildCard).action) {
        case uppo.WildCardAction.DrawNone:
          text = "Wild";
          break;
        case uppo.WildCardAction.DrawFour:
          text = "Wild +4";
          break;
      }

      faceTexts = [
        Positioned(
            top: 0 * scale,
            left: -24 * scale,
            right: 0,
            child: Text(text.substring(0, 1),
                textAlign: TextAlign.center,
                style: google_fonts.GoogleFonts.kalam(
                    textStyle: TextStyle(
                        height: 1,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 400 * scale,
                        color: Color.fromRGBO(0, 0, 0, 0.1))))),
        Positioned(
            top: 25 * scale,
            left: 0,
            right: 0,
            child: Text(text,
                textAlign: TextAlign.center,
                style: google_fonts.GoogleFonts.kalam(
                    textStyle: TextStyle(
                        height: 1,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 44 * scale,
                        color: Color.fromRGBO(0, 0, 0, 0.6)))))
      ];
    }

    switch (card.color) {
      case uppo.CardColor.Red:
        faceColor = RED_BOLD;
        faceArt = Positioned(
            bottom: -13 * scale,
            left: -20 * scale,
            child: Container(
                width: 150 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage("assets/red_hippo.png"),
                ))));
        break;
      case uppo.CardColor.Green:
        faceColor = GREEN_BOLD;
        faceArt = Positioned(
            bottom: -0 * scale,
            right: -20 * scale,
            child: Container(
                width: 150 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage("assets/green_hippo.png"),
                ))));
        break;
      case uppo.CardColor.Yellow:
        faceColor = YELLOW_BOLD;
        faceArt = Positioned(
            bottom: -10 * scale,
            left: -110 * scale,
            child: Container(
                width: 300 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage("assets/yellow_hippo.png"),
                ))));
        break;
      case uppo.CardColor.Blue:
        faceColor = BLUE_BOLD;
        faceArt = Positioned(
            bottom: -10 * scale,
            left: 20 * scale,
            child: Container(
                width: 200 * scale,
                height: 135 * scale,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage("assets/blue_hippo.png"),
                ))));
        break;
      default:
        faceColor = HIPPO_GREY;
        faceArt = Positioned(
            bottom: -30 * scale,
            right: -10 * scale,
            child: Container(
                width: 180 * scale,
                height: 230 * scale,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage("assets/wild_hippo.png"),
                ))));
    }

    if (card is uppo.CommandCard) {
      var command = (card as uppo.CommandCard).command;
      if (command.startsWith("Wild_Pick")) {
        var assetImage = {
          uppo.CardColor.Blue: "assets/wild_hippo_blue.png",
          uppo.CardColor.Red: "assets/wild_hippo_red.png",
          uppo.CardColor.Green: "assets/wild_hippo_green.png",
          uppo.CardColor.Yellow: "assets/wild_hippo_yellow.png",
        };
        faceArt = Positioned(
            bottom: -30 * scale,
            right: -10 * scale,
            child: Container(
                width: 180 * scale,
                height: 230 * scale,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: FractionalOffset.topCenter,
                  image: AssetImage(assetImage[card.color]),
                ))));

        switch (command) {
          case "Wild_Pick":
            text = "Wild";
            break;
          case "Wild_PickDraw4":
            text = "Wild +4";
            break;
        }

        faceTexts = [
          Positioned(
              top: 0 * scale,
              left: -24 * scale,
              right: 0,
              child: Text(text.substring(0, 1),
                  textAlign: TextAlign.center,
                  style: google_fonts.GoogleFonts.kalam(
                      textStyle: TextStyle(
                          height: 1,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 400 * scale,
                          color: Color.fromRGBO(0, 0, 0, 0.1))))),
          Positioned(
              top: 25 * scale,
              left: 0,
              right: 0,
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: google_fonts.GoogleFonts.kalam(
                      textStyle: TextStyle(
                          height: 1,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 44 * scale,
                          color: Color.fromRGBO(0, 0, 0, 0.6)))))
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.addAll(faceTexts);
    children.add(faceArt);
    return Transform.rotate(
        angle: angle,
        child: CardBorder(
            child: Container(
              decoration: BoxDecoration(
                  color: faceColor,
                  borderRadius: BorderRadius.circular(10 * scale)),
              width: 200 * scale,
              height: 280 * scale,
              child: Stack(children: children),
            ),
            scale: scale,
            floating: this.floating));
  }
}

class DroppedNotification extends Notification {
  final uppo.Card card;
  final Offset offset;
  const DroppedNotification({this.offset, this.card});
}

class DraggableCardWidget extends StatelessWidget {
  final uppo.Card card;

  DraggableCardWidget({@required this.card});

  @override
  Widget build(BuildContext context) {
    var cardWidget =
        AdvancedCardWidget(card: card, angle: 0, scale: 0.75, floating: true);

    var childWhenDragging = BasicCardWidget(
        value: "",
        backgroundColor: Color.fromRGBO(255, 255, 255, 0),
        borderColor: Color.fromRGBO(0, 0, 0, 0),
        textColor: Color.fromRGBO(0, 0, 0, 0.3));

    var draggable = Draggable(
      affinity: Axis.vertical,
      data: card.id,
      feedback: cardWidget,
      child: AdvancedCardWidget(card: card, angle: 0, scale: 0.5),
      childWhenDragging: childWhenDragging,
      onDragEnd: (details) {
        if (details.wasAccepted) {
          DroppedNotification(card: card, offset: details.offset)
              .dispatch(context);
        }
      },
    );

    return Container(
        width: BasicCardWidget.width,
        height: BasicCardWidget.height,
        child: draggable); //Cursor(child: draggable));
  }
}
