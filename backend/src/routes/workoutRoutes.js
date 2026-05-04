const express = require("express");
const WorkoutSession = require("../models/WorkoutSession");
const Exercise = require("../models/Exercise");

const { calculateLoadFactor } = require("../services/loadEngine");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

const upperBodyGroups = [
  "pecho",
  "espalda",
  "hombros",
  "brazos",
  "biceps",
  "triceps"
];

const lowerBodyGroups = [
  "piernas",
  "gluteos",
  "glúteos",
  "cuadriceps",
  "cuádriceps",
  "isquios",
  "femorales",
  "pantorrillas"
];

function normalizeText(value) {
  return String(value || "")
    .toLowerCase()
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function filterExercisesByTarget(exercises, targetMuscleGroup) {
  const normalizedTarget = normalizeText(targetMuscleGroup || "full_body");

  if (normalizedTarget === "full_body" || normalizedTarget === "full body") {
    return exercises;
  }

  if (
    normalizedTarget === "tren_superior" ||
    normalizedTarget === "tren superior" ||
    normalizedTarget === "upper"
  ) {
    return exercises.filter((exercise) =>
      upperBodyGroups.includes(normalizeText(exercise.muscleGroup))
    );
  }

  if (
    normalizedTarget === "tren_inferior" ||
    normalizedTarget === "tren inferior" ||
    normalizedTarget === "lower"
  ) {
    return exercises.filter((exercise) =>
      lowerBodyGroups.includes(normalizeText(exercise.muscleGroup))
    );
  }

  return exercises.filter(
    (exercise) => normalizeText(exercise.muscleGroup) === normalizedTarget
  );
}

// Generar y guardar la sesión
router.post("/generate", protect, async (req, res) => {
  const userId = req.user.id;

  const {
    sleep,
    pain,
    fatigue,
    stress,
    mood,
    targetMuscleGroup = "full_body"
  } = req.body;

  const result = await calculateLoadFactor({
    sleep,
    pain,
    fatigue,
    stress,
    mood
  });

  let workoutExercises = [];
  let trainedMuscleGroups = [];

  if (result.factor > 0) {
    const sets = result.factor === 1 ? 4 : 2;

    const dbExercises = await Exercise.find({ isActive: true });

    let filteredExercises = filterExercisesByTarget(
      dbExercises,
      targetMuscleGroup
    );

    // Si no hay ejercicios para ese grupo, usamos full body como respaldo
    if (filteredExercises.length === 0) {
      filteredExercises = dbExercises;
    }

    workoutExercises = filteredExercises.map((exercise) => ({
      exerciseId: exercise._id,
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      sets: sets,
      reps: "10-12",
      videoUrl: exercise.videoUrl,
      instructions: exercise.instructions
    }));

    trainedMuscleGroups = [
      ...new Set(
        workoutExercises.map((exercise) => exercise.muscleGroup)
      )
    ];
  }

  try {
    const newSession = await WorkoutSession.create({
      userId,
      targetMuscleGroup,
      trainedMuscleGroups,
      loadFactor: result.factor,
      recommendationLabel: result.label,
      exercises: workoutExercises
    });

    res.status(201).json({
      message: result.message,
      sessionId: newSession._id,
      loadFactor: result.factor,
      recommendation: result.label,
      targetMuscleGroup,
      trainedMuscleGroups,
      exercises: workoutExercises
    });
  } catch (error) {
    console.error("Error al guardar la sesión:", error);
    res.status(500).json({ message: "Error interno del servidor" });
  }
});

// Registrar el RPE asociado a una sesión específica
router.post("/:sessionId/rpe", protect, async (req, res) => {
  const { sessionId } = req.params;
  const { rpe } = req.body;

  if (!rpe || rpe < 1 || rpe > 10) {
    return res.status(400).json({
      message: "El RPE debe estar entre 1 y 10"
    });
  }

  try {
    const updatedSession = await WorkoutSession.findByIdAndUpdate(
      sessionId,
      {
        rpe: rpe,
        completedAt: new Date()
      },
      { new: true }
    );

    if (!updatedSession) {
      return res.status(404).json({
        message: "Sesión de entrenamiento no encontrada"
      });
    }

    res.json({
      message: "RPE registrado y sesión completada",
      session: updatedSession
    });
  } catch (error) {
    console.error("Error al registrar RPE:", error);
    res.status(500).json({
      message: "Error interno al actualizar la sesión"
    });
  }
});

module.exports = router;