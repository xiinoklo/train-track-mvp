const express = require("express");
const cors = require("cors");

const exerciseRoutes = require("./routes/exerciseRoutes");
const workoutRoutes = require("./routes/workoutRoutes");

const app = express();

const PORT = 3000;

app.use(cors());
app.use(express.json());

const wellnessEntries = [];

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    app: "TrainTrack API"
  });
});

app.use("/api/exercises", exerciseRoutes);
app.use("/api/workouts", workoutRoutes);

app.post("/api/wellness", (req, res) => {
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

app.get("/api/wellness", (req, res) => {
  res.json({
    total: wellnessEntries.length,
    wellnessEntries: wellnessEntries
  });
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});