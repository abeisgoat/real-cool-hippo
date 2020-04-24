const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const actions = require("./actions");

exports.startGameWhenReady = functions.firestore
  .document("/games/{gid}/statuses/{uid}")
  .onWrite(async (change, context) => {
    var gameDoc = change.after.ref.parent.parent;
    await actions.startGame({ gid: gameDoc.id });
  });

// exports.purgeAncients = functions.

// firebase.firestore().collection("games").where("t", ">", 1586998218).get().then((snapshot) => snapshot.docs.forEach((doc) => console.log(doc.data())))
//     exports.scheduledFunctionCrontab = functions.pubsub.schedule('5 11 * * *')
//     .timeZone('America/New_York') // Users can choose timezone - default is America/Los_Angeles
//     .onRun((context) => {
//         console.log('This will be run every day at 11:05 AM Eastern!');
//         return null;
//     });

exports.ready = functions.https.onCall(actions.ready);
exports.joinGame = functions.https.onCall(actions.joinGame);
exports.play = functions.https.onCall(actions.play);
exports.helloWorld = functions.https.onCall(actions.helloWorld);
