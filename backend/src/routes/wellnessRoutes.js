const express = require("express");

const router = express.Router();

const wellnessEntries = [];

router.post("/", (req, res) => {
  const { sleep, pain, fatigue, stress, mood } = req.body;

  if (
    !sleep ||
    !pain ||
    !fatigue ||
    !stress ||
    !mood ||
    sleep < 1 ||
    sleep > 5 ||
    pain < 1 ||
    pain > 5 ||
    fatigue < 1 ||
    fatigue > 5 ||
    stress < 1 ||
    stress > 5 ||
    mood < 1 ||
    mood > 5
  ) {
    return res.status(400).json({
      message: "Todos los valores de bienestar deben estar entre 1 y 5"
    });
  }

  const wellnessEntry = {
    id: `wellness-${Date.now()}`,
    sleep,
    pain,
    fatigue,
    stress,
    mood,
    createdAt: new Date().toISOString()
  };

  wellnessEntries.push(wellnessEntry);

  console.log("Bienestar registrado:", wellnessEntry);

  res.status(201).json({
    message: "Bienestar registrado correctamente",
    wellness: wellnessEntry
  });
});

router.get("/", (req, res) => {
  res.json({
    total: wellnessEntries.length,
    wellnessEntries: wellnessEntries
  });
});

module.exports = router;