import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/main.dart';
import 'package:uppo/player_metadata.dart';
import 'package:uppo/server.dart';
import 'package:uppo/widgets/bottom_bar.dart';
import 'package:uppo/widgets/countdown.dart';
import 'package:uppo/widgets/crummy_button.dart';
import 'package:uppo/widgets/hoverable.dart';
import 'package:uppo/widgets/toast.dart';
import 'package:uppo/widgets/version.dart';
import '../cursor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class HorizontalLineText extends StatelessWidget {
  final String text;
  final bool header;
  final bool hasTopPadding;

  HorizontalLineText(this.text,
      {this.header = false, this.hasTopPadding = true});

  @override
  Widget build(BuildContext context) {
    var lineColor = Color.fromRGBO(0, 0, 0, 1);
    return Container(
        padding: EdgeInsets.only(
          top: hasTopPadding ? 15 : 5,
          left: 20,
          right: 20,
          bottom: 15,
        ),
        child: Row(children: [
          Flexible(flex: 1, child: Container(height: 3, color: lineColor)),
          Padding(
              child: Text(text,
                  style: GoogleFonts.luckiestGuy(
                      textStyle: TextStyle(
                          fontSize: header ? 30 : 14,
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(0, 0, 0, 1)))),
              padding: EdgeInsets.symmetric(horizontal: 10)),
          Flexible(flex: 1, child: Container(height: 3, color: lineColor)),
        ]));
  }
}

class MemberList extends StatelessWidget {
  final String nickname;
  final String gameId;
  final String uid;
  final Map<String, PlayerMetadata> players;
  final List<String> invites;

  MemberList(
      {@required this.nickname,
      @required this.gameId,
      @required this.players,
      @required this.uid,
      @required this.invites});

  String _toFormattedGameID(String id) {
    return id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    var playerMetadatas = players.values.toList();

    var colors = [
      YELLOW_PASTEL,
      GREEN_PASTEL,
      RED_PASTEL,
      BLUE_PASTEL,
      HIPPO_GREY
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: EdgeInsets.only(top: 10, bottom: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Share this code:",
              style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.normal,
                  fontSize: 24)),
          SelectableText(" ${_toFormattedGameID(gameId)} ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ]),
      ),
      HorizontalLineText("then"),
      Flexible(
        flex: 1,
        child: Column(
            children: [0, 1, 2, 3, 4].map((int index) {
          PlayerMetadata pm;
          if (playerMetadatas.length > index) {
            pm = playerMetadatas[index];
          }

          var nameLine = pm != null
              ? Text(
                  "${pm.name} ${pm.id == uid ? "(You)" : ""}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : Text(invites[index],
                  style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      fontWeight: FontWeight.bold));

          var nameIcon;

          if (pm == null) {
            nameIcon = Icon(Icons.access_time, color: Colors.grey, size: 20);
          } else if (pm.ready) {
            nameIcon = Icon(Icons.check, color: Colors.black, size: 20);
          } else {
            nameIcon = Icon(Icons.autorenew, color: Colors.black, size: 20);
          }

          return Container(
              padding: EdgeInsets.only(bottom: 5, right: 5, left: 5),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[nameLine, nameIcon],
                ),
                decoration: BoxDecoration(
                    color: pm != null
                        ? colors[index]
                        : Color.fromRGBO(255, 255, 255, 0.3),
                    border: Border.all(
                        color: pm != null
                            ? Colors.black45
                            : Color.fromRGBO(255, 255, 255, 0),
                        width: 2),
                    borderRadius: BorderRadius.circular(30)),
              ));
        }).toList()),
      )
    ]);
  }
}

class MatchMakingScreen extends StatefulWidget {
  final String gameId;
  final String uid;

  MatchMakingScreen({Key key, @required this.gameId, @required this.uid})
      : super(key: key);

  @override
  _MatchMakingScreenState createState() => _MatchMakingScreenState();
}

class _MatchMakingScreenState extends State<MatchMakingScreen> {
  _setGameIDFromInput() {
    _otherGameID = _otherGameID.replaceAll("-", "").toUpperCase();

    if (_otherGameID.length != 4) {
      ToastSingleton.show("Game ID must be four characters!");
      return;
    }
    _doJoin(_otherGameID);
  }

  _setGameIDFromRandom() {
    var gameId = _newGameID();
    _doJoin(gameId);
  }

  _doJoin(String gameId) async {
    var result = await UppoServer.join({"name": _nickname, "gid": gameId});

    if (result.data["status"] == "GAME_STARTED") {
      ToastSingleton.show("Could not join game, it has already started.");
      LobbySingleton.gameId.value = null;
    } else if (result.data["status"] == "GAME_FULL") {
      ToastSingleton.show("Could not join game, too many players");
      LobbySingleton.gameId.value = null;
    } else {
      LobbySingleton.gameId.value = gameId;
    }
  }

  _clearGameID() {
    LobbySingleton.gameId.value = null;
  }

  _readyUp() {
    print("ready up");
    UppoServer.ready({"gid": LobbySingleton.gameId.value, "ready": true});
  }

  _readyDown() {
    print("ready down");
    UppoServer.ready({"gid": LobbySingleton.gameId.value, "ready": false});
  }

  final _tecNickname = TextEditingController();
  final _tecOtherGameID = TextEditingController();

  final invites = [
    "Invite your bestie",
    "Invite your coworker",
    "Invite your crush",
    "Invite your dog",
    "Invite your friend",
    "Invite your auntie",
    "Invite your imaginary friend",
    "Invite your friend",
    "Invite your boss",
    "Invite your homie",
    "Invite your enemy",
  ];

  String _nickname = "";
  String _otherGameID = "";

  @override
  void dispose() {
    _tecNickname.dispose();
    _tecOtherGameID.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _tecNickname.addListener(() {
      setState(() {
        _nickname = _tecNickname.text;
      });
    });

    _tecOtherGameID.addListener(() {
      setState(() {
        _otherGameID = _tecOtherGameID.text.trim();
      });
    });

    invites.shuffle();
  }

  final chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  String _newGameID() {
    var rng = new math.Random();
    String result = "";
    for (var i = 0; i < 4; i++) {
      result += chars[rng.nextInt(chars.length)];
    }
    return result;
  }

  Widget _textField(Key key, TextEditingController tec,
      {bool enabled = true, String label, String hint, int maxLength}) {
    var border = const OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black, width: 2.0),
    );
    return TextField(
      key: key,
      maxLength: maxLength,
      autocorrect: false,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold),
      enabled: enabled,
      controller: tec,
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          hintText: hint,
          enabledBorder: border,
          focusedBorder: border,
          disabledBorder: border,
          fillColor: Colors.white,
          filled: true,
          counterText: ""),
    );
  }

  Widget _getJoinScreen() {
    var children = [
      HorizontalLineText("Play a game", header: true, hasTopPadding: false),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              height: 45,
              child: _textField(Key("TextField_Nickname"), _tecNickname,
                  maxLength: 10, label: 'Nickname'))
        ],
      ),
      HorizontalLineText("then"),
      CrummyButton(
          key: Key("Button_StartGame"),
          text: "Start a New Game",
          onTap: _setGameIDFromRandom,
          onDisabledTap: () {
            ToastSingleton.show(
                "You must enter a nickname before starting a game.");
          },
          enabled: _nickname.length >= 3),
      HorizontalLineText("or"),
      Container(
          height: 45,
          child: Opacity(
              opacity: _nickname.length >= 3 ? 1 : 0.5,
              child: _textField(Key("TextField_OtherGameID"), _tecOtherGameID,
                  maxLength: 10,
                  enabled: _nickname.length >= 3,
                  label: "Friend's Game ID (XXXX)"))),
      Container(width: 10, height: 10),
      CrummyButton(
          key: Key("Button_JoinGame"),
          text: "Join Friend's Game",
          onTap: _setGameIDFromInput,
          onDisabledTap: () {
            ToastSingleton.show(
                "You must enter a nickname before joining a game.");
          },
          enabled: _nickname.length >= 3),
      HorizontalLineText(
        "Extras",
        header: true,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BottomBar.item("Rules", Icons.announcement, rounded: true, onTap: () {
            ModalSingleton.active.value = Modals.Rules;
          }),
//          BottomBar.item("Leagues", Icons.folder_shared,
//              rounded: true, onTap: () {ModalSingleton.active.value = Modals.Leagues;}),
          BottomBar.item("Credits", Icons.info_outline, rounded: true,
              onTap: () {
            ModalSingleton.active.value = Modals.Credits;
          }),
        ],
      ),
      Version(),
    ];

    return Container(
        child: Column(mainAxisSize: MainAxisSize.min, children: children));
  }

  Widget _getLobbyScreen() {
    return ValueListenableBuilder<Map<String, PlayerMetadata>>(
      valueListenable: LobbySingleton.players,
      builder: (ctx, players, child) {
        var readyPlayerCount = players.values.where((pm) => pm.ready).length;
        var playerCount = players.length;

        var isAllReady = readyPlayerCount == playerCount;
        var isReady =
            players.containsKey(widget.uid) && players[widget.uid].ready;

        Widget readyButton;
        Key readyButtonKey = Key("Button_Start");

        readyButton = ValueListenableBuilder(
            valueListenable: UppoServer.hasPendingOperations,
            builder: (context, hasPendingOps, child) {


              if (hasPendingOps) {
                return CrummyButton(
                    key: readyButtonKey,
                    text: "Working on it...",
                    onTap: _readyUp,
                    enabled: false);
              } else if (playerCount == 0) {
                return CrummyButton(
                    key: readyButtonKey,
                    text: "Connecting...",
                    onTap: _readyUp,
                    enabled: false);
              } else if (playerCount == 1) {
                return CrummyButton(
                    key: readyButtonKey,
                    text: "Waiting for friends...",
                    onTap: _readyUp,
                    enabled: false);
              } else if (!isReady) {
                return CrummyButton(
                    key: readyButtonKey,
                    text: "Ready ($readyPlayerCount/$playerCount)",
                    onTap: _readyUp);
              } else if (isReady && !isAllReady) {
                return CrummyButton(
                    key: readyButtonKey,
                    text: "Ready ($readyPlayerCount/$playerCount)",
                    onTap: _readyDown);
              } else if (isReady && isAllReady) {
                return CrummyButton(
                    key: Key("Button_Start"),
                    child: Countdown(seconds: 3),
                    onTap: _readyDown);
              } else {
                return Text("error");
              }
            });

        var children = [
          Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: LobbySingleton.gameId.value == null
                  ? Text("  No game id  ")
                  : MemberList(
                      gameId: LobbySingleton.gameId.value,
                      nickname: _nickname,
                      players: players,
                      uid: widget.uid,
              invites: invites,)),
          HorizontalLineText("When you're ready"),
          readyButton,
          HorizontalLineText("or"),
          CrummyButton(
            key: Key("Button_Cancel"),
            text: "Cancel",
            lightmode: true,
            onTap: _clearGameID,
          )
        ];
        ;

        return Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 400.0;

    return Container(
//        width: maxWidth,
        child: Center(
            child: SingleChildScrollView(
                child: Center(
                    child: Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              height: 210,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                alignment: FractionalOffset.bottomCenter,
                                image: AssetImage("assets/logo.png"),
                              ))),
                          DefaultTextStyle(
                              style: TextStyle(color: Colors.black),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: widget.gameId == null
                                    ? _getJoinScreen()
                                    : _getLobbyScreen(),
                              )),
                        ]))))));
  }
}
