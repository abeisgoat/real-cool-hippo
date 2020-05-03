import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:uppo/constants.dart';
import 'package:uppo/effects.dart';
import 'package:uppo/localstorage.dart';
import 'package:uppo/server.dart';
import 'package:uppo/utils.dart';
import 'package:uppo/widgets/animated_translate.dart';
import 'package:uppo/widgets/bottom_bar.dart';
import 'package:uppo/widgets/confirm.dart';
import 'package:uppo/widgets/effect_draw_card.dart';
import 'package:uppo/widgets/effect_opponent_card.dart';
import 'package:uppo/widgets/effect_play_card.dart';
import 'package:uppo/widgets/endgame.dart';
import 'package:uppo/widgets/markdown_modal.dart';
import 'package:uppo/widgets/played_area.dart';
import 'package:uppo/widgets/toast.dart';
import 'package:uppo/widgets/topbar.dart';
import 'package:uppo/widgets/wild_selector.dart';

import 'widgets/card.dart';
import 'widgets/opponent_hand.dart';
import 'widgets/match_making.dart';
import 'widgets/player_hand.dart';
import 'player_metadata.dart';

import './uppo/uppo.dart' as uppo;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      home: MyHomePage(title: "Real Cool Hippo"),
      theme: ThemeData(
        brightness: Brightness.light,

        primarySwatch: Colors.grey,
        primaryColor: Colors.grey[50],
        primaryColorBrightness: Brightness.light,

        //this is what you want
        accentColor: Colors.grey[50],
        accentColorBrightness: Brightness.light,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class QuitNotification extends Notification {
  QuitNotification():super();
}

class OpponentPositioning {
  final Alignment alignment;
  final SpreadDirection direction;

  OpponentPositioning({this.alignment, this.direction});
}

class LobbySingleton {
  static var gameId = ValueNotifier<String>(null);
  static var gss = ValueNotifier<uppo.GameStateSnapshot>(null);
  static var hand = ValueNotifier<uppo.CardBundle>(null);
  static var uid = ValueNotifier<String>(null);
  static var players = ValueNotifier<Map<String, PlayerMetadata>>({});

  static reset() {
    gss.value = null;
    hand.value = null;
    players.value = {};
    gameId.value = null;
  }
}

enum Involvement { Player, Viewer }
enum Modals { None, Rules, Credits, Leagues }

class ModalSingleton {
  static ValueNotifier active = ValueNotifier(Modals.None);
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final LocalStorage localStorage = new LocalStorage('rch');
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

  EffectRegistry<uppo.GameStateSnapshot> gssEffects;
  EffectRegistry<uppo.CardBundle> drawEffects;
  EffectRegistry<EffectPlayCardBundle> playEffects;
  EffectRegistry<uppo.GameStateSnapshot> opponentEffects;

  Offset _playAreaOffset;

  Involvement _involvement;

  List<StreamSubscription> _cancels = [];

  @override
  void initState() {
    super.initState();
    _auth.signInAnonymously();
    _auth.onAuthStateChanged.listen((user) {
      if (user == null) return;
      LobbySingleton.uid.value = user.uid;
    });

    LobbySingleton.gameId.addListener(() async {
      var gameId = LobbySingleton.gameId.value;
      setState(() {
        // To reload top level router;
      });

      _cancelSubscriptions();

      if (gameId == null || gameId == "") {
        print("No game id, not connecting.");
        localStorage.removeItem("gid");
        return;
      }

      print("Game ID: $gameId");
      localStorage.setItem("gid", gameId);

      drawEffects = EffectRegistry();
      gssEffects = EffectRegistry();
      playEffects = EffectRegistry();
      opponentEffects = EffectRegistry();
      var gameDoc = _firestore.document("games/$gameId");

      // Subscribe to main state changes
      _cancels.add(gameDoc.snapshots().listen((snapshot) async {
        if (snapshot == null ||
            snapshot.data == null ||
            snapshot.data["s"] == null) {
          print("Can't update gss, no snapshot");
          return;
        }

        var after = uppo.GameStateSnapshot.fromMap(
            masterDeck: MASTER_DECK, map: snapshot.data["s"]);
        transitionToGSS(after);
      }));

      // Subscribe to player name / hand counts
      _cancels.add(
          gameDoc.collection("players").snapshots().listen((snapshots) async {
        snapshots.documents.forEach((doc) {
          var pm = LobbySingleton.players.value[doc.documentID];
          if (pm == null) pm = PlayerMetadata();

          pm.id = doc.documentID;
          pm.name = doc.data["name"];
          pm.count = doc.data["count"];

          LobbySingleton.players.value[doc.documentID] = pm;
          LobbySingleton.players.notifyListeners();
        });
      }));

      // Subscribe to player name / hand counts
      _cancels.add(
          gameDoc.collection("statuses").snapshots().listen((snapshots) async {
        snapshots.documents.forEach((doc) {
          var pm = LobbySingleton.players.value[doc.documentID];
          if (pm == null) pm = PlayerMetadata();

          pm.ready = doc.data["ready"];

          LobbySingleton.players.value[doc.documentID] = pm;
        });

        LobbySingleton.players.notifyListeners();
      }));

      var user = await _auth.currentUser();
      _cancels.add(_firestore
          .document("games/${LobbySingleton.gameId.value}/private/${user.uid}")
          .snapshots()
          .listen((snapshot) async {
        var oldInvolvement = _involvement;
        if (!snapshot.exists) {
          _involvement = Involvement.Viewer;
          print("No hand for this player :/");
          return;
        } else {
          _involvement = Involvement.Player;
        }

        if (oldInvolvement != _involvement) {
          print("SS for involvement");
          setState(() {});
        }

        if (!drawEffects.locked) {
          var pm = LobbySingleton.players.value[user.uid];
          if (pm == null) pm = PlayerMetadata();

          pm.hand = uppo.CardBundle.fromString(
              masterDeck: MASTER_DECK, string: snapshot.data["bundle"]);

          LobbySingleton.hand.value = pm.hand;

          LobbySingleton.players.value[user.uid] = pm;
          LobbySingleton.players.notifyListeners();
        }
      }));
    });

    LobbySingleton.gameId.value = localStorage.getItem("gid");
  }

  void transitionToGSS(uppo.GameStateSnapshot after) async {
    var gss = LobbySingleton.gss.value;
    var players = LobbySingleton.players.value;
    if (players.length > 0 && gss != null) {
      var beforePlayer = players[getPlayerIDByIndex(players, gss.livePlayer)];

      if (beforePlayer.id != LobbySingleton.uid.value &&
          gss.liveCardId != after.liveCardId) {
        print("Someone else played a card: ${beforePlayer.name}");

        var skipAnimation =
            MASTER_DECK.ccs("Wild_Pick").contains(after.liveCardId) ||
                MASTER_DECK.ccs("Wild_PickDraw4").contains(after.liveCardId);

        if (skipAnimation) {
          LobbySingleton.gss.value = after;
          return;
        } else {
          await opponentEffects.effects[beforePlayer.id]
              .performEffect(gss, after);
          return;
        }
      } else {
        await playEffects.wait();
        LobbySingleton.gss.value = after;
        return;
      }
    } else {
      LobbySingleton.gss.value = after;
    }

    print("Fresh game");
    setState(() {});
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _cancels.forEach((sub) {
      sub.cancel();
    });
    _cancels = [];
  }

  void _drawCard() async {
    var hand = LobbySingleton.hand.value;
    var turnCards = hand
        .getCards()
        .where((card) =>
            (card is uppo.CommandCard) && card.command.startsWith("Turn"))
        .map((card) => card.id)
        .toList();

    if (drawEffects.locked) {
      ToastSingleton.show("You can't draw, it's not your turn!");
      print("Can't draw, still on last card");
      return;
    }

    if (turnCards.length == 0) {
      ToastSingleton.show("You can't draw, it's not your turn!");
      return;
    }

    var bundle = hand.toString();
    drawEffects.lock();
    try {
      var resp = await UppoServer.play(
          {"cid": turnCards[0], "gid": LobbySingleton.gameId.value});
      bundle = resp.data["bundle"].toString();
    } catch (err) {
      print(err);
      print("Server Error, fuck.");
    }

    var nextHand = uppo.CardBundle.fromString(
        masterDeck: LobbySingleton.gss.value.masterDeck, string: bundle);

    await drawEffects.performEffects(hand, nextHand);

    LobbySingleton.hand.value = nextHand;
    drawEffects.unlock();
  }

  void _quit() {
    LobbySingleton.reset();
  }

  Widget _getGameScreen() {
    List<OpponentPositioning> opponentPositioning = [
      OpponentPositioning(
          alignment: Alignment(1, -.65), direction: SpreadDirection.Right),
      OpponentPositioning(
          alignment: Alignment(-1, -.65), direction: SpreadDirection.Left),
      OpponentPositioning(
          alignment: Alignment(-1, -.25), direction: SpreadDirection.Left),
      OpponentPositioning(
          alignment: Alignment(1, -.25), direction: SpreadDirection.Right),
      OpponentPositioning(
          alignment: Alignment(-1, .05), direction: SpreadDirection.Left),
      OpponentPositioning(
          alignment: Alignment(1, .05), direction: SpreadDirection.Right),
    ];

    List<Widget> tableChildren = [];

    var opponentIndex = 0;
    LobbySingleton.players.value.forEach((id, pm) {
      if (id == LobbySingleton.uid.value) return;
      var positioning = opponentPositioning[opponentIndex];

      tableChildren.add(Container(
          alignment: positioning.alignment,
          child: OpponentHand(
              spreadDirection: positioning.direction, player: pm)));

      opponentIndex++;
    });

    tableChildren.add(Positioned(
        bottom: 60,
        left: 0,
        right: 0,
        child: Center(
          child: NotificationListener(
              child: Container(
                  child: PlayerHand(handListener: LobbySingleton.hand)),
              onNotification: (notification) {
                if (notification is DroppedNotification) {
                  playEffects.performEffects(
                      EffectPlayCardBundle(offset: notification.offset),
                      EffectPlayCardBundle(
                          offset: _playAreaOffset, card: notification.card));
                }
                return false;
              }),
//              ,
        )));

    tableChildren.add(Align(alignment: Alignment.topCenter, child: Topbar()));

    tableChildren.add(Positioned(
        bottom: 60,
        left: 0,
        right: 0,
        top: 0,
        child: WildSelector(
          handListener: LobbySingleton.hand,
          onSelection: (cardId) {
            UppoServer.applyPlay(cardId);
          },
        )));

    tableChildren.add(Positioned(
        top: 0,
        right: 0,
        left: 0,
        bottom: BottomBar.height,
        child: NotificationListener(
          child: PlayedArea(),
          onNotification: (notification) {
            if (notification is OffsetNotification) {
              _playAreaOffset = notification.offset;
            }

            return false;
          },
        )));

    opponentIndex = 0;
    LobbySingleton.players.value.forEach((id, pm) {
      if (id == LobbySingleton.uid.value) return;
      var positioning = opponentPositioning[opponentIndex];

      tableChildren.add(EffectOpponentCard(
        registry: opponentEffects,
        id: pm.id,
        direction: positioning.direction,
        alignment: positioning.alignment,
      ));
      opponentIndex++;
    });

    tableChildren.add(Align(
        alignment: Alignment.bottomCenter,
        child: EffectDrawCard(registry: drawEffects)));

    tableChildren.add(Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: BottomBar(items: [
          BottomBar.item("Quit", Icons.exit_to_app, onTap: () {
            ConfirmSingleton.show(ConfirmBundle(
              message: "The game can't continue without you! Are you sure you want to quit?",
              onConfirm: _quit
            ));
          }),
//          BottomBar.item("Rules", Icons.announcement, onTap: () {
//            ModalSingleton.active.value = Modals.Rules;
//          }),
          _involvement == Involvement.Player
              ? ValueListenableBuilder(
                  valueListenable: drawEffects.lockNotifier,
                  builder: (ctx, isLocked, child) {
                    return BottomBar.item("Draw", Icons.library_add,
                        onTap: _drawCard, enabled: !isLocked);
                  },
                )
              : null,
          Padding(
              child: _involvement == Involvement.Player
                  ? ValueListenableBuilder<uppo.CardBundle>(
                      valueListenable: LobbySingleton.hand,
                      builder: (ctx, hand, child) {
                        var handCardCount = hand != null
                            ? hand
                                .getCards()
                                .where((card) => !(card is uppo.CommandCard))
                                .length
                            : 0;

                        return Tooltip(
                          message: "You have ${handCardCount} cards",
                          child: Text("x${handCardCount}",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        );
                      })
                  : Container(),
              padding: EdgeInsets.only(left: 16, top: 6))
        ])));

    tableChildren.add(EffectPlayCard(registry: playEffects));

    tableChildren.add(Positioned(
        top: 0,
        right: 0,
        left: 0,
        bottom: 0,
        child: NotificationListener(
            child: EndGame(), onNotification: (notification) {
              if (notification is QuitNotification) {
                _quit();
              }
        })));

    return Stack(children: tableChildren);
  }

  Widget _getMatchMakingScreen() {
    return ValueListenableBuilder(
      valueListenable: LobbySingleton.uid,
      builder: (ctx, uid, child) {
        return MatchMakingScreen(
          gameId: LobbySingleton.gameId.value,
          uid: LobbySingleton.uid.value,
        );
      },
    );
  }

  Widget _getBackground({Widget child}) {
    return Container(
        child: child,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background.png"),
              repeat: ImageRepeat.repeat),
          gradient: RadialGradient(
            radius: LobbySingleton.gss.value != null ? 0.5 : 0.7,
            colors: [
              const Color.fromRGBO(183, 183, 183, 1), // yellow sun
              const Color.fromRGBO(210, 210, 210, 1), // blue sky
            ],
            stops: [0.4, 1.0], // repeats the gradient over the canvas
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> globalChildren = [];

    globalChildren.add(LobbySingleton.gss.value != null
        ? _getGameScreen()
        : _getMatchMakingScreen());

    globalChildren
        .add(MarkdownModal(asset: "assets/RULES.md", modal: Modals.Rules));
    globalChildren
        .add(MarkdownModal(asset: "assets/CREDITS.md", modal: Modals.Credits));

    globalChildren.add(Confirm());
    globalChildren.add(Toast());

    return Scaffold(
        body: Title(
            title: "Real Cool Hippo",
            color: Colors.black,
            child: _getBackground(child: ValueListenableBuilder(valueListenable: LobbySingleton.gameId, builder: (ctx, gameId, child) {
              return Stack(children: globalChildren);
            },))));
  }
}
