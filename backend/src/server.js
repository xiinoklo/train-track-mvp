const express = require("express");
const cors = require("cors");

const app = express();

const PORT = 3000;

app.use(cors());
app.use(express.json());

const exercises = [
  {
    id: "ex-001",
    name: "Press de banca",
    level: "principiante",
    muscleGroup: "pecho",
    description: "Ejercicio de empuje horizontal para tren superior.",
    instructions: "Mantén la espalda estable, baja controlado y empuja sin bloquear los codos.",
    videoUrl: "https://www.youtube.com/watch?v=rT7DgCr-3pg",
    isActive: true
  },
  {
    id: "ex-002",
    name: "Remo en polea baja",
    level: "principiante",
    muscleGroup: "espalda",
    description: "Ejercicio de tracción para espalda.",
    instructions: "Lleva los codos hacia atrás y evita inclinar demasiado el torso.",
    videoUrl: "https://www.youtube.com/watch?v=GZbfZ033f74",
    isActive: true
  },
  {
    id: "ex-003",
    name: "Sentadilla goblet",
    level: "principiante",
    muscleGroup: "piernas",
    description: "Ejercicio básico para tren inferior.",
    instructions: "Mantén el pecho arriba, baja controlado y empuja desde los talones.",
    videoUrl: "https://www.youtube.com/watch?v=MeIiIdhvXT4",
    isActive: true
  }
];

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    app: "TrainTrack API"
  });
});

function calculateLoadFactor({ sleep, pain, fatigue, stress, mood }) {
  if (pain >= 4 || fatigue >= 5) {
    return {
      factor: 0,
      label: "Descanso recomendado",
      message: "Hoy se recomienda descanso o movilidad suave por dolor o fatiga alta."
    };
  }

  if (sleep <= 2 || stress >= 4 || fatigue >= 4 || mood <= 2) {
    return {
      factor: 0.5,
      label: "Sesión reducida",
      message: "Hoy se recomienda reducir volumen e intensidad."
    };
  }

  return {
    factor: 1,
    label: "Sesión normal",
    message: "Estado favorable para realizar la sesión planificada."
  };
}

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

app.get("/api/exercises", (req, res) => {
  res.json({
    total: exercises.length,
    exercises: exercises
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

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});