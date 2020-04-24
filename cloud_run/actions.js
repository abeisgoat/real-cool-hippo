const path = require("path");
const admin = require("firebase-admin");
const child_process = require("child_process");

function cli(command, args) {
  const argList = Object.keys(args).map((key) => `--${key}=${args[key]}`);
  console.log(__dirname, argList);
  const result = child_process
    .execFileSync(path.join(__dirname, "./cli.exe"), [command, ...argList])
    .toString();
  return result;
}

async function saveState(gameDoc, sortedPlayers, state) {
  const bundles = JSON.parse(JSON.stringify(state["b"]));

  const promises = Object.keys(bundles).reduce((p, bundleKey) => {
    const [id, _] = bundleKey.split("^");

    if (!id) {
      return p;
    }

    delete state["b"][bundleKey];

    p.push(
      gameDoc
        .collection("private")
        .doc(id)
        .set({ bundle: bundles[bundleKey] }, { merge: true })
    );

    p.push(
      gameDoc
        .collection("players")
        .doc(id)
        .set({ count: state["_c"][id] }, { merge: true })
    );

    return p;
  }, []);

  delete state["_c"];

  promises.push(
    gameDoc.set({ s: state, t: admin.firestore.FieldValue.serverTimestamp() })
  );
  await Promise.all(promises);
}

async function startGame(data) {
  const gameDoc = admin.firestore().doc(`games/${data.gid}/`);
  const sortedPlayers = await getSortedPlayers(gameDoc);

  console.log(`Starting game ${data.gid} with ${sortedPlayers.length} players`);

  const after = cli("new", {
    seed: data.gid,
    players: sortedPlayers.map((playerSnapshot) => playerSnapshot.id),
  });
  await saveState(gameDoc, sortedPlayers, JSON.parse(after));
}

async function getGameReadyStatus(ref) {
  return (await ref.get()).docs
    .map((doc) => doc.data().ready)
    .reduce((ready, playerReady) => {
      if (!ready) return false;

      return playerReady;
    }, true);
}

async function wait(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

exports.startGame = async (data, context) => {
  var gameRef = admin.firestore().doc(`games/${data.gid}`);
  var statusesRef = gameRef.collection("statuses")
  var isReady = await getGameReadyStatus(statusesRef);
  if (!isReady) {
    console.log("Some play  er isn't ready...");
    return;
  }

  const gameSnapshot = [
      await gameRef.get(),
      await wait(4000)
  ][0];

  var isStillReady = await getGameReadyStatus(statusesRef);

  if (!isStillReady) {
    console.log("Someone backed out...");
    return;
  }

  if (gameSnapshot.data() && gameSnapshot.data().s) {
    console.log("This game already started, not starting again...");
    return;
  }

  await startGame(data);
};

async function getSortedPlayers(gameDoc, collection="players") {
  const playerSnapshots = await gameDoc.collection(collection).get();
  return JSON.parse(
    cli("sort", {
      players: playerSnapshots.docs.map((doc) => doc.id),
    })
  ).map((id) => playerSnapshots.docs.filter((doc) => doc.id == id)[0]);
}

exports.joinGame = async (data, context) => {
  const gameDoc = admin.firestore().doc(`games/${data.gid}`);

  const playerRef = gameDoc.collection(`players`).doc(context.auth.uid);
  const statusRef = gameDoc.collection(`statuses`).doc(context.auth.uid);

  var [gameSnapshot, playerSnapshots] = [await gameDoc.get(), await gameDoc.collection("players").get()];

  if (gameSnapshot.data() && gameSnapshot.data().s) {
    return {status: "GAME_STARTED"};
  }

  if (playerSnapshots.docs.length >= 5) {
    return {status: "GAME_FULL"};
  }

  [
    await playerRef.set({ name: data.name }),
    await statusRef.set({ ready: false }),
    await gameDoc.set(
      { t: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    ),
  ];

  return {status: "JOINED"};
};

exports.play = async (data, context) => {
  const gameId = data.gid;
  const cardId = data.cid;
  const gameDoc = admin.firestore().doc(`games/${gameId}/`);

  const [gameSnapshot, sortedPlayers] = await Promise.all([
    await gameDoc.get(),
    await getSortedPlayers(gameDoc, "private"),
  ]);

  const before = gameSnapshot.data().s;

  sortedPlayers.forEach((playerDoc) => {
    before.b[playerDoc.id] = playerDoc.data().bundle;
  });

  const after = cli("play", {
    before: JSON.stringify(before),
    player: context.auth.uid,
    card: cardId,
  });

  if (after.startsWith("LegalResponse.Rejected")) {
    console.warn("Rejected: ", after);
    return {
      command: data,
      id: context.auth.uid,
      bundle: before["b"][`${context.auth.uid}`],
    };
  }

  console.log("Accepted");
  console.log(after);
  const afterObj = JSON.parse(after);
  const bundle = afterObj["b"][`${context.auth.uid}`];
  // Todo: This is dangerous
  saveState(gameDoc, sortedPlayers, afterObj);
  return { command: data, id: context.auth.uid, bundle };
};

exports.ready = async (data, context) => {
  const gameDoc = admin.firestore().doc(`games/${data.gid}`);
  const playerDoc = gameDoc.collection("statuses").doc(context.auth.uid);
  [
    await playerDoc.set({ ready: data.ready }, { merge: true }),
    await gameDoc.set({ t: admin.firestore.FieldValue.serverTimestamp() }),
  ];
};

exports.helloWorld = async (data, context) => {
  await wait(5000);
  return { hello: "world" };
};
