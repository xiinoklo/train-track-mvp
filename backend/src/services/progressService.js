const XP_PER_LEVEL = 500;
const MAX_LEVEL = 9;
const DAILY_XP_LIMIT = 40;

function getStartingLevel(experienceLevel) {
  if (experienceLevel === "intermedio") return 4;
  if (experienceLevel === "avanzado") return 7;
  return 1;
}

function getLevelFromXp(xp) {
  return Math.min(MAX_LEVEL, Math.floor((xp || 0) / XP_PER_LEVEL) + 1);
}

function getRankFromLevel(level) {
  const safeLevel = Math.min(Math.max(level || 1, 1), MAX_LEVEL);
  const subLevel = ((safeLevel - 1) % 3) + 1;

  if (safeLevel <= 3) return `Principiante ${subLevel}`;
  if (safeLevel <= 6) return `Intermedio ${subLevel}`;
  return `Avanzado ${subLevel}`;
}

function getExperienceFromLevel(level) {
  if (level <= 3) return "principiante";
  if (level <= 6) return "intermedio";
  return "avanzado";
}

function calculateWorkoutXp({ exercises, loadFactor, rpe }) {
  const exerciseXp = Array.isArray(exercises)
    ? exercises.reduce((total, exercise) => total + Math.max(0, Number(exercise.xp) || 0), 0)
    : 0;
  const loadMultiplier = loadFactor === 0.5 ? 0.75 : loadFactor > 0 ? 1 : 0;
  const effortBonus = rpe >= 6 && rpe <= 8 ? 5 : 0;

  return Math.max(0, Math.round(exerciseXp * loadMultiplier) + effortBonus);
}

module.exports = {
  XP_PER_LEVEL,
  MAX_LEVEL,
  DAILY_XP_LIMIT,
  getStartingLevel,
  getLevelFromXp,
  getRankFromLevel,
  getExperienceFromLevel,
  calculateWorkoutXp
};
