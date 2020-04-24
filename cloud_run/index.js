const app = require("express")();
const bodyParser = require("body-parser");
const actions = require("./actions");
const admin = require("firebase-admin");
admin.initializeApp();

app.use(bodyParser.json());
app.use((req, res, next) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set(
    "Access-Control-Allow-Methods",
    "GET, POST, PATCH, PUT, DELETE, OPTIONS"
  );
  res.set(
    "Access-Control-Allow-Headers",
    "authorization, content-type, referer, user-agent"
  );
  next();
});

app.post("/:projectId/:region/:functionName", async (req, res) => {
  const data = req.body.data;
  const context = { rawRequest: req };

  try {
    const decodedIdToken = await admin
      .auth()
      .verifyIdToken(req.headers["authorization"].split("Bearer ")[1]);
    context.auth = { uid: decodedIdToken.uid, idToken: decodedIdToken };
  } catch (err) {
    console.warn("Unauthenticated request");
  }

  res.json({
    data: (await actions[req.params["functionName"]](data, context)) || {},
  });
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log("Listening on port", port);
});
