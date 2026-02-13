const express = require("express");
const cors = require("cors");
app.use(cors());

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("BharatPath AI backend running");
});

app.get("/monuments", async (req, res) => {
  try {
    const snapshot = await db.collection("monuments").get();
    const monuments = snapshot.docs.map(doc => doc.data());
    res.json(monuments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/recommendations", async (req, res) => {
  const userInterests = req.body.interests;

  try {
    const snapshot = await db.collection("monuments").get();
    const monuments = snapshot.docs.map(doc => doc.data());

    const scored = monuments.map(m => {
      const score = m.tags.filter(tag => userInterests.includes(tag)).length;
      return { ...m, score };
    });

    scored.sort((a, b) => b.score - a.score);
    res.json(scored.slice(0, 10));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/smart-search", async (req, res) => {
  const query = req.body.query.toLowerCase();

  // Intent keywords mapping
  const intentMap = {
    spirituality: ["spiritual", "peace", "meditation", "temple"],
    history: ["history", "historical", "ancient"],
    architecture: ["architecture", "design", "monument"],
    nature: ["nature", "scenic", "mountain", "river"],
    less_crowded: ["quiet", "peaceful", "less crowded"]
  };

  // Detect intents
  const detectedIntents = [];

  for (const intent in intentMap) {
    if (intentMap[intent].some(word => query.includes(word))) {
      detectedIntents.push(intent);
    }
  }

  try {
    const snapshot = await db.collection("monuments").get();
    const monuments = snapshot.docs.map(doc => doc.data());

    const scored = monuments.map(m => {
      const score = m.tags.filter(tag => detectedIntents.includes(tag)).length;
      return { ...m, score };
    });

    scored.sort((a, b) => b.score - a.score);

    res.json({
      query,
      detectedIntents,
      results: scored.filter(m => m.score > 0)
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});



