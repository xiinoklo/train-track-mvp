const express = require("express");
const cors = require("cors");

const exercises = require("./data/exercises");
const { calculateLoadFactor } = require("./services/loadEngine");
const exerciseRoutes = require("./routes/exerciseRoutes");

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

app.post("/api/workouts/generate", (req, res) => {
  const { sleep, pain, fatigue, stress, mood } = req.body;

  const result = calculateLoadFactor({
    sleep,
    pain,
    fatigue,
    stress,
    mood
  });

  if (result.factor === 0) {
    return res.json({
      loadFactor: result.factor,
      recommendation: result.label,
      message: result.message,
      exercises: []
    });
  }

  const sets = result.factor === 1 ? 4 : 2;

  const workoutExercises = exercises.map((exercise) => ({
    id: exercise.id,
    name: exercise.name,
    muscleGroup: exercise.muscleGroup,
    sets: sets,
    reps: "10-12",
    instructions: exercise.instructions,
    videoUrl: exercise.videoUrl
  }));

  res.json({
    loadFactor: result.factor,
    recommendation: result.label,
    message: result.message,
    exercises: workoutExercises
  });
});

app.post("/api/workouts/rpe", (req, res) => {
  const { rpe } = req.body;

  if (!rpe || rpe < 1 || rpe > 10) {
    return res.status(400).json({
      message: "El RPE debe estar entre 1 y 10"
    });
  }

  console.log("RPE recibido:", rpe);

  res.json({
    message: "RPE registrado correctamente",
    rpe: rpe
  });
});

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