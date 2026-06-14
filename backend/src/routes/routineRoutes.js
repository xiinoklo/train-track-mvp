const express = require("express");
const mongoose = require("mongoose");
const SavedRoutine = require("../models/SavedRoutine");
const WorkoutSession = require("../models/WorkoutSession");
const User = require("../models/User");
const Exercise = require("../models/Exercise");
const { protect } = require("../middleware/authMiddleware");
const { getExperienceFromLevel } = require("../services/progressService");

const router = express.Router();

function sanitizeExercises(exercises) {
  if (!Array.isArray(exercises)) return [];

  return exercises
    .filter((exercise) => exercise && exercise.name)
    .map((exercise) => ({
      exerciseId: exercise.exerciseId,
      name: String(exercise.name).trim(),
      muscleGroup: String(exercise.muscleGroup || "general").trim(),
      sets: Math.min(8, Math.max(1, Number(exercise.sets) || 3)),
      reps: String(exercise.reps || "10-12").trim(),
      weight: String(exercise.weight || "").trim(),
      videoUrl: exercise.videoUrl || "",
      instructions: exercise.instructions || "",
      xp: 0
    }));
}

async function hydrateExerciseXp(exercises) {
  const ids = exercises
    .map((exercise) => exercise.exerciseId)
    .filter((id) => mongoose.Types.ObjectId.isValid(id));
  const catalogExercises = await Exercise.find({ _id: { $in: ids } })
    .select("_id xp")
    .lean();
  const xpMap = new Map(
    catalogExercises.map((exercise) => [
      exercise._id.toString(),
      Math.max(0, Number(exercise.xp) || 0)
    ])
  );

  return exercises.map((exercise) => ({
    ...exercise,
    xp: xpMap.get(String(exercise.exerciseId || "")) || 0
  }));
}

async function requireAdvanced(req, res, next) {
  const user = await User.findById(req.user.id).select("experienceLevel level");
  const experienceLevel =
    user?.experienceLevel || getExperienceFromLevel(user?.level || 1);

  if (!user || experienceLevel !== "avanzado") {
    return res.status(403).json({
      message: "Solo los usuarios avanzados pueden gestionar rutinas propias"
    });
  }

  next();
}

router.use(protect, requireAdvanced);

router.get("/", async (req, res) => {
  const routines = await SavedRoutine.find({ userId: req.user.id }).sort({
    updatedAt: -1
  });
  res.json({ routines });
});

router.post("/", async (req, res) => {
  const name = String(req.body.name || "").trim();
  const exercises = await hydrateExerciseXp(
    sanitizeExercises(req.body.exercises)
  );

  if (!name || exercises.length === 0) {
    return res.status(400).json({
      message: "Nombre y al menos un ejercicio son obligatorios"
    });
  }

  const routine = await SavedRoutine.create({
    userId: req.user.id,
    name,
    exercises
  });

  res.status(201).json({ message: "Rutina guardada", routine });
});

router.post("/:id/start", async (req, res) => {
  const routine = await SavedRoutine.findOne({
    _id: req.params.id,
    userId: req.user.id
  });

  if (!routine) {
    return res.status(404).json({ message: "Rutina no encontrada" });
  }

  const exercises = await hydrateExerciseXp(
    sanitizeExercises(routine.exercises)
  );
  const trainedMuscleGroups = [
    ...new Set(exercises.map((exercise) => exercise.muscleGroup))
  ];
  const session = await WorkoutSession.create({
    userId: req.user.id,
    targetMuscleGroup: "custom",
    trainedMuscleGroups,
    loadFactor: 1,
    recommendationLabel: "Rutina personalizada",
    exercises
  });

  res.status(201).json({
    sessionId: session._id,
    loadFactor: session.loadFactor,
    recommendation: session.recommendationLabel,
    message: `Rutina "${routine.name}" lista para entrenar`,
    exercises,
    canCustomizeWorkout: true,
    canSaveCustomRoutine: true
  });
});

router.put("/:id", async (req, res) => {
  const updates = {};
  if (req.body.name !== undefined) updates.name = String(req.body.name).trim();
  if (req.body.exercises !== undefined) {
    updates.exercises = await hydrateExerciseXp(
      sanitizeExercises(req.body.exercises)
    );
  }

  const routine = await SavedRoutine.findOneAndUpdate(
    { _id: req.params.id, userId: req.user.id },
    updates,
    { new: true, runValidators: true }
  );

  if (!routine) {
    return res.status(404).json({ message: "Rutina no encontrada" });
  }

  res.json({ message: "Rutina actualizada", routine });
});

router.delete("/:id", async (req, res) => {
  const routine = await SavedRoutine.findOneAndDelete({
    _id: req.params.id,
    userId: req.user.id
  });

  if (!routine) {
    return res.status(404).json({ message: "Rutina no encontrada" });
  }

  res.json({ message: "Rutina eliminada" });
});

module.exports = router;
