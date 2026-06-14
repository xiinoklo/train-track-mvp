const WorkoutSession = require("../models/WorkoutSession");

const muscleGroups = [
  "pecho",
  "espalda",
  "piernas",
  "hombros",
  "brazos",
  "core",
  "biceps",
  "triceps",
  "gluteos",
  "cuadriceps",
  "isquios",
  "femorales",
  "pantorrillas"
];

const muscleGroupHierarchy = [
  { group: "pecho", muscles: ["pecho"] },
  { group: "espalda", muscles: ["espalda"] },
  { group: "hombros", muscles: ["hombros"] },
  { group: "brazos", muscles: ["biceps", "triceps"] },
  {
    group: "piernas",
    muscles: ["gluteos", "cuadriceps", "isquios", "femorales", "pantorrillas"]
  },
  { group: "core", muscles: ["core"] }
];

function normalizeText(value) {
  return String(value || "")
    .toLowerCase()
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function getRestHoursByRpe(rpe) {
  if (!rpe) return 24;
  if (rpe <= 5) return 24;
  if (rpe <= 7) return 48;
  return 72;
}

function getHoursSince(date) {
  return (new Date() - new Date(date)) / (1000 * 60 * 60);
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

function sessionAffectsMuscle(session, muscleGroup) {
  const target = normalizeText(muscleGroup);
  const trainedGroups = getMuscleGroupsFromSession(session).map(normalizeText);

  if (trainedGroups.includes(target)) {
    return true;
  }

  return muscleGroupHierarchy.some(({ group, muscles }) => {
    const parent = normalizeText(group);
    const children = muscles.map(normalizeText);

    if (target === parent) {
      return trainedGroups.some((trained) => children.includes(trained));
    }

    return children.includes(target) && trainedGroups.includes(parent);
  });
}

function getRecoveryColor(remainingHours, requiredRestHours, hoursSinceTraining) {
  if (remainingHours <= 0) return "green";
  if (hoursSinceTraining / requiredRestHours >= 0.5) return "yellow";
  return "red";
}

async function getCompletedSessions(userId) {
  return WorkoutSession.find({
    userId,
    completedAt: { $ne: null }
  }).sort({ completedAt: -1 });
}

async function getMuscleRecoveryStatus(userId) {
  const completedSessions = await getCompletedSessions(userId);
  const statusMap = {};

  for (const muscleGroup of muscleGroups) {
    const muscleKey = normalizeText(muscleGroup);
    const lastSession = completedSessions.find((session) =>
      sessionAffectsMuscle(session, muscleKey)
    );

    if (!lastSession) {
      statusMap[muscleKey] = "green";
      continue;
    }

    const requiredRestHours = getRestHoursByRpe(lastSession.rpe);
    const hoursSinceTraining = getHoursSince(lastSession.completedAt);
    const remainingHours = requiredRestHours - hoursSinceTraining;

    statusMap[muscleKey] = getRecoveryColor(
      remainingHours,
      requiredRestHours,
      hoursSinceTraining
    );
  }

  return statusMap;
}

async function getMuscleRecoveryDetails(userId) {
  const completedSessions = await getCompletedSessions(userId);

  return muscleGroups.map((muscleGroup) => {
    const muscleKey = normalizeText(muscleGroup);
    const lastSession = completedSessions.find((session) =>
      sessionAffectsMuscle(session, muscleKey)
    );

    if (!lastSession) {
      return {
        muscleGroup,
        status: "ready",
        recoveryColor: "green",
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
    const recoveryColor = getRecoveryColor(
      remainingHours,
      requiredRestHours,
      hoursSinceTraining
    );

    return {
      muscleGroup,
      status: remainingHours === 0 ? "ready" : "rest",
      recoveryColor,
      message:
        remainingHours === 0
          ? "Listo para entrenar"
          : `Descansar ${remainingHours} h mas`,
      remainingHours,
      lastTrainedAt: lastSession.completedAt,
      lastRpe: lastSession.rpe
    };
  });
}

module.exports = {
  muscleGroups,
  muscleGroupHierarchy,
  normalizeText,
  sessionAffectsMuscle,
  getMuscleRecoveryStatus,
  getMuscleRecoveryDetails
};
