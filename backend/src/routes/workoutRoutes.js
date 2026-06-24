const express = require("express");
const WorkoutSession = require("../models/WorkoutSession");
const Exercise = require("../models/Exercise");
const User = require("../models/User");

const { calculateLoadFactor } = require("../services/loadEngine");
const {
  getMuscleRecoveryDetails,
  getMuscleRecoveryStatus,
  muscleGroups,
  normalizeText
} = require("../services/muscleRecoveryService");
const {
  calculateWorkoutXp,
  getExperienceFromLevel,
  getLevelFromXp,
  getRankFromLevel,
  getStartingLevel,
  XP_PER_LEVEL,
  DAILY_XP_LIMIT
} = require("../services/progressService");
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
  "gl\u00fateos",
  "cuadriceps",
  "cu\u00e1driceps",
  "isquios",
  "femorales",
  "pantorrillas"
];

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

function getRecoveryDetailMap(recoveryDetails) {
  return recoveryDetails.reduce((map, item) => {
    map[normalizeText(item.muscleGroup)] = item;
    return map;
  }, {});
}

function getTargetMuscleKeys(targetMuscleGroup) {
  const normalizedTarget = normalizeText(targetMuscleGroup || "full_body");

  if (normalizedTarget === "full_body" || normalizedTarget === "full body") {
    return muscleGroups.map(normalizeText);
  }

  if (
    normalizedTarget === "tren_superior" ||
    normalizedTarget === "tren superior" ||
    normalizedTarget === "upper"
  ) {
    return upperBodyGroups.map(normalizeText);
  }

  if (
    normalizedTarget === "tren_inferior" ||
    normalizedTarget === "tren inferior" ||
    normalizedTarget === "lower"
  ) {
    return lowerBodyGroups.map(normalizeText);
  }

  return [normalizedTarget];
}

function getBlockedBeginnerMuscles(targetMuscleGroup, recoveryDetailMap) {
  return getTargetMuscleKeys(targetMuscleGroup)
    .map((muscleKey) => recoveryDetailMap[muscleKey])
    .filter(
      (recoveryDetail) =>
        recoveryDetail && recoveryDetail.remainingHours > 24
    );
}

function sanitizeCustomExercises(exercises, originalExercises = []) {
  if (!Array.isArray(exercises)) return null;

  const xpByExerciseId = new Map(
    originalExercises.map((exercise) => [
      String(exercise.exerciseId || ""),
      Math.max(0, Number(exercise.xp) || 0)
    ])
  );

  return exercises.map((exercise) => ({
    exerciseId: exercise.exerciseId,
    name: exercise.name,
    muscleGroup: exercise.muscleGroup,
    sets: Number(exercise.sets) || 1,
    reps: String(exercise.reps || "10-12").trim(),
    weight: String(exercise.weight || "").trim(),
    videoUrl: exercise.videoUrl || "",
    instructions: exercise.instructions || "",
    xp: xpByExerciseId.get(String(exercise.exerciseId || "")) || 0
  }));
}

function getTodayRange() {
  const start = new Date();
  start.setUTCHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setUTCDate(end.getUTCDate() + 1);
  return { start, end };
}

router.post("/generate", protect, async (req, res) => {
  try {
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

    const user = await User.findById(userId).select("experienceLevel level");

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado"
      });
    }

    const experienceLevel =
      user.experienceLevel || getExperienceFromLevel(user.level || 1);
    const canCustomizeWorkout = experienceLevel !== "principiante";
    const canSaveCustomRoutine = experienceLevel === "avanzado";
    const muscleStatus = await getMuscleRecoveryStatus(userId);
    const recoveryDetails = await getMuscleRecoveryDetails(userId);
    const recoveryDetailMap = getRecoveryDetailMap(recoveryDetails);
    const blockedBeginnerMuscles =
      experienceLevel === "principiante"
        ? getBlockedBeginnerMuscles(targetMuscleGroup, recoveryDetailMap)
        : [];

    let workoutExercises = [];
    let trainedMuscleGroups = [];

    if (result.factor > 0) {
      if (blockedBeginnerMuscles.length > 0) {
        const blockedNames = blockedBeginnerMuscles
          .map(
            (recoveryDetail) =>
              `${recoveryDetail.muscleGroup} (${recoveryDetail.remainingHours}h)`
          )
          .join(", ");

        return res.status(201).json({
          message: `No puedes entrenar ${targetMuscleGroup} todavia. Estos musculos necesitan mas descanso: ${blockedNames}.`,
          sessionId: null,
          loadFactor: 0,
          recommendation: "Descanso muscular activo",
          targetMuscleGroup,
          trainedMuscleGroups: [],
          exercises: [],
          muscleStatusSummary: muscleStatus,
          recoveryDetails,
          blockedMuscles: blockedBeginnerMuscles,
          canCustomizeWorkout,
          canSaveCustomRoutine
        });
      }

      const sets = result.factor === 1 ? 4 : 2;

      const dbExercises = await Exercise.find({ isActive: true });

      let filteredExercises = filterExercisesByTarget(
        dbExercises,
        targetMuscleGroup
      );

      if (filteredExercises.length === 0) {
        filteredExercises = dbExercises;
      }

      if (filteredExercises.length === 0) {
        return res.status(201).json({
          message:
            experienceLevel === "principiante"
              ? "Tus musculos objetivo aun necesitan mas de 24 horas de descanso. Elige otro grupo o prioriza movilidad suave."
              : "Todos tus musculos objetivo estan en periodo de descanso. Se recomienda movilidad suave o descanso activo.",
          sessionId: null,
          loadFactor: 0,
          recommendation: "Descanso muscular activo",
          targetMuscleGroup,
          trainedMuscleGroups: [],
          exercises: [],
          muscleStatusSummary: muscleStatus,
          recoveryDetails,
          canCustomizeWorkout,
          canSaveCustomRoutine
        });
      }

      workoutExercises = filteredExercises.map((exercise) => ({
        exerciseId: exercise._id,
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets,
        reps: "10-12",
        weight: "",
        videoUrl: exercise.videoUrl,
        instructions: exercise.instructions,
        xp: exercise.xp
      }));

      trainedMuscleGroups = [
        ...new Set(workoutExercises.map((exercise) => exercise.muscleGroup))
      ];
    }

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
      exercises: workoutExercises,
      muscleStatusSummary: muscleStatus,
      recoveryDetails,
      canCustomizeWorkout,
      canSaveCustomRoutine,
      experienceLevel
    });
  } catch (error) {
    console.error("Error al generar la sesion:", error);
    res.status(500).json({ message: "Error interno del servidor" });
  }
});

router.post("/:sessionId/rpe", protect, async (req, res) => {
  const { sessionId } = req.params;
  const { rpe, exercises } = req.body;

  if (!rpe || rpe < 1 || rpe > 10) {
    return res.status(400).json({
      message: "El RPE debe estar entre 1 y 10"
    });
  }

  try {
    const session = await WorkoutSession.findOne({
      _id: sessionId,
      userId: req.user.id
    });

    if (!session) {
      return res.status(404).json({
        message: "Sesion de entrenamiento no encontrada"
      });
    }

    const user = await User.findById(req.user.id).select(
      "experienceLevel level xp"
    );

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado"
      });
    }

    const experienceLevel =
      user.experienceLevel || getExperienceFromLevel(user.level || 1);
    const canCustomizeWorkout = experienceLevel !== "principiante";
    const customExercises = canCustomizeWorkout
      ? sanitizeCustomExercises(exercises, session.exercises)
      : null;
    const alreadyAwardedXp = (session.xpAwarded || 0) > 0;

    session.rpe = rpe;
    session.completedAt = new Date();

    if (customExercises && customExercises.length > 0) {
      session.exercises = customExercises;
      session.trainedMuscleGroups = [
        ...new Set(customExercises.map((exercise) => exercise.muscleGroup))
      ];
    }

    let xpGained = 0;

    if (!alreadyAwardedXp) {
      xpGained = calculateWorkoutXp({
        exercises: session.exercises,
        loadFactor: session.loadFactor,
        rpe
      });

      const { start, end } = getTodayRange();
      const dailyXpResult = await WorkoutSession.aggregate([
        {
          $match: {
            userId: user._id,
            _id: { $ne: session._id },
            completedAt: { $gte: start, $lt: end }
          }
        },
        { $group: { _id: null, total: { $sum: "$xpAwarded" } } }
      ]);
      const xpAwardedToday = dailyXpResult[0]?.total || 0;
      xpGained = Math.min(
        xpGained,
        Math.max(0, DAILY_XP_LIMIT - xpAwardedToday)
      );

      const minimumXp =
        (getStartingLevel(experienceLevel) - 1) * XP_PER_LEVEL;

      user.xp = Math.max(user.xp || 0, minimumXp) + xpGained;
      user.level = getLevelFromXp(user.xp);
      user.experienceLevel = getExperienceFromLevel(user.level);
      session.xpAwarded = xpGained;

      await user.save();
    }

    await session.save();

    res.json({
      message: "RPE registrado y sesion completada",
      session,
      xpGained,
      userProgress: {
        xp: user.xp,
        level: user.level,
        rank: getRankFromLevel(user.level),
        experienceLevel: user.experienceLevel,
        xpInLevel: user.xp % XP_PER_LEVEL,
        xpNeeded: XP_PER_LEVEL,
        dailyXpLimit: DAILY_XP_LIMIT
      }
    });
  } catch (error) {
    console.error("Error al registrar RPE:", error);
    res.status(500).json({
      message: "Error interno al actualizar la sesion"
    });
  }
});

module.exports = router;
