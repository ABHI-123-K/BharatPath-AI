const admin = require("firebase-admin");
const fs = require("fs");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const monuments = JSON.parse(
  fs.readFileSync("../data/monuments.json", "utf8")
);

async function upload() {
  for (const monument of monuments) {
    await db.collection("monuments").doc(monument.id).set(monument);
    console.log("Uploaded:", monument.name);
  }
  console.log("All monuments uploaded successfully.");
}

upload();
