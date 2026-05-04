const express = require("express");
const WorkoutSession = require("../models/WorkoutSession");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

const muscleGroups = [
  "pecho",
  "espalda",
  "piernas",
  "hombros",
  "brazos",
  "core"
];

function getRestHoursByRpe(rpe) {
  if (!rpe) return 24;

  if (rpe <= 5) return 24;
  if (rpe <= 7) return 48;
  return 72;
}

function getHoursSince(date) {
  const now = new Date();
  const past = new Date(date);
  const diffMs = now - past;

  return diffMs / (1000 * 60 * 60);
}

function getMuscleGroupsFromSession(session) {
  if (
    Array.isArray(session.trainedMuscleGroups) &&
    session.trainedMuscleGroups.length > 0
  ) {
    return session.trainedMuscleGroups;
  }

  if (Array.isArray(session.exercises)) {
    return [
      ...new Set(
        session.exercises
          .map((exercise) => exercise.muscleGroup)
          .filter(Boolean)
      )
    ];
  }

  return [];
}

router.get("/", protect, async (req, res) => {
  try {
    const userId = req.user.id;

    const completedSessions = await WorkoutSession.find({
      userId,
      completedAt: { $ne: null }
    }).sort({ completedAt: -1 });

    const recovery = muscleGroups.map((muscleGroup) => {
      const lastSession = completedSessions.find((session) => {
        const groups = getMuscleGroupsFromSession(session);
        return groups.includes(muscleGroup);
      });

      if (!lastSession) {
        return {
          muscleGroup,
          status: "ready",
          message: "Listo para entrenar",
          remainingHours: 0,
          lastTrainedAt: null,
          lastRpe: null
        };
      }

      const requiredRestHours = getRestHoursByRpe(lastSession.rpe);
      const hoursSinceTraining = getHoursSince(lastSession.completedAt);
      const remainingHours = Math.max(
        0,
        Math.ceil(requiredRestHours - hoursSinceTraining)
      );

      if (remainingHours === 0) {
        return {
          muscleGroup,
          status: "ready",
          message: "Listo para entrenar",
          remainingHours: 0,
          lastTrainedAt: lastSession.completedAt,
          lastRpe: lastSession.rpe
        };
      }

      return {
        muscleGroup,
        status: "rest",
        message: `Descansar ${remainingHours} h más`,
        remainingHours,
        lastTrainedAt: lastSession.completedAt,
        lastRpe: lastSession.rpe
      };
    });

    res.json({
      total: recovery.length,
      recovery
    });
  } catch (error) {
    console.error("Error al calcular recuperación muscular:", error);

    res.status(500).json({
      message: "Error interno al calcular recuperación muscular"
    });
  }
});

module.exports = router;