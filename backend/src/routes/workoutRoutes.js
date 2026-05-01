const express = require("express");

const exercises = require("../data/exercises");
const { calculateLoadFactor } = require("../services/loadEngine");

const router = express.Router();

router.post("/generate", (req, res) => {
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

router.post("/rpe", (req, res) => {
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

module.exports = router;