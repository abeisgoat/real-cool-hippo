import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/widgets/card.dart';
import '../uppo/uppo.dart' as uppo;

typedef WildSelectorHandler = void Function(int cardId);

class WildSelector extends StatefulWidget {
  ValueNotifier<uppo.CardBundle> handListener;
  WildSelectorHandler onSelection;
  WildSelector({Key key, this.handListener, this.onSelection})
      : super(key: key);

  @override
  _WildSelector createState() => _WildSelector();
}

class _WildSelector extends State<WildSelector> {
  uppo.CardColor _selected = null;

  double _width = 300.0;
  double _height = 350.0;

  var options = {
    uppo.CardColor.Blue: {
      "card_color": uppo.CardColor.Blue,
      "text": "Blue",
      "alignment": Alignment.topLeft,
      "color": BLUE_BOLD,
      "hover_color": BLUE_PASTEL,
      "text_alignment": Alignment.topCenter
    },
    uppo.CardColor.Red: {
      "card_color": uppo.CardColor.Red,
      "text": "Red",
      "alignment": Alignment.topRight,
      "color": RED_BOLD,
      "hover_color": RED_PASTEL,
      "text_alignment": Alignment.topCenter
    },
    uppo.CardColor.Green: {
      "card_color": uppo.CardColor.Green,
      "text": "Green",
      "alignment": Alignment.bottomRight,
      "color": GREEN_BOLD,
      "hover_color": GREEN_PASTEL,
      "text_alignment": Alignment.bottomCenter
    },
    uppo.CardColor.Yellow: {
      "card_color": uppo.CardColor.Yellow,
      "text": "Yellow",
      "alignment": Alignment.bottomLeft,
      "color": YELLOW_BOLD,
      "hover_color": YELLOW_PASTEL,
      "text_alignment": Alignment.bottomCenter
    }
  };

  Widget _getOption(option, showWildcardSelector) {
    var optionWidth = (_width / 2) - 5.0;
    var optionHeight = (_height / 2) - 5.0;

    return GestureDetector(
        onTap: () {
          widget.onSelection(option["id"]);
        },
        child: CardBorder(
            width: optionWidth,
            height: optionHeight,
            scale: 0.75,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: _selected == option["card_color"]
                      ? option["hover_color"]
                      : option["color"],
                ),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(showWildcardSelector ? option["text"] : "",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kalam(
                          textStyle: TextStyle(
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Color.fromRGBO(0, 0, 0, 0.6)))),
                  alignment: option["text_alignment"],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<uppo.CardBundle>(
      valueListenable: widget.handListener,
      builder: (ctx, hand, child) {
        var commandCards = 0;
        (hand != null ? hand.getCards() : []).forEach((card) {
          if (card is uppo.CommandCard &&
              card.command.startsWith("Wild_Pick")) {
            options[card.color]["id"] = card.id;
            commandCards++;
          }
        });
        bool _showWildSelector = commandCards == 4;

        return Stack(
          children: <Widget>[
            Center(
                child: MouseRegion(
                    onExit: (pointEvent) {
                      setState(() {
                        _selected = null;
                      });
                    },
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: _width,
                        height: _height,
                        child: Stack(
                          children: options.values
                              .map(
                                (option) => AnimatedAlign(
                                    duration: Duration(
                                        milliseconds:
                                            _showWildSelector ? 400 : 200),
                                    curve: _showWildSelector
                                        ? Curves.bounceOut
                                        : Curves.linear,
                                    alignment: _showWildSelector
                                        ? option["alignment"]
                                        : Alignment.center,
                                    child: MouseRegion(
                                        onHover: (pointEvent) {
                                          setState(() {
                                            _selected = option["card_color"];
                                          });
                                        },
                                        child: _getOption(
                                            option, _showWildSelector))),
                              )
                              .toList(),
                        )))),
          ],
        );
      },
    );
  }
}
