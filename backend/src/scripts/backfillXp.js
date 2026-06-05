require("dotenv").config();
const mongoose = require("mongoose");
const User = require("../models/User");
const WorkoutSession = require("../models/WorkoutSession");
const {
  XP_PER_LEVEL,
  calculateWorkoutXp,
  getExperienceFromLevel,
  getLevelFromXp,
  getStartingLevel
} = require("../services/progressService");

async function backfillUserXp(user) {
  const sessions = await WorkoutSession.find({
    userId: user._id,
    completedAt: { $ne: null },
    rpe: { $ne: null },
    $or: [{ xpAwarded: { $exists: false } }, { xpAwarded: 0 }, { xpAwarded: null }]
  }).sort({ completedAt: 1 });

  if (sessions.length === 0) {
    return {
      email: user.email,
      sessionsUpdated: 0,
      xpAdded: 0
    };
  }

  let xpAdded = 0;
  let experienceLevel =
    user.experienceLevel || getExperienceFromLevel(user.level || 1);

  for (const session of sessions) {
    const xp = calculateWorkoutXp({
      experienceLevel,
      loadFactor: session.loadFactor,
      rpe: session.rpe
    });

    session.xpAwarded = xp;
    await session.save();

    xpAdded += xp;
  }

  const minimumXp = (getStartingLevel(experienceLevel) - 1) * XP_PER_LEVEL;
  user.xp = Math.max(user.xp || 0, minimumXp) + xpAdded;
  user.level = getLevelFromXp(user.xp);
  user.experienceLevel = getExperienceFromLevel(user.level);

  await user.save();

  return {
    email: user.email,
    sessionsUpdated: sessions.length,
    xpAdded,
    xp: user.xp,
    level: user.level,
    experienceLevel: user.experienceLevel
  };
}

async function main() {
  const email = process.argv[2];

  await mongoose.connect(process.env.MONGO_URI);

  const users = email
    ? await User.find({ email: email.toLowerCase().trim() })
    : await User.find({});

  const results = [];

  for (const user of users) {
    results.push(await backfillUserXp(user));
  }

  console.log(JSON.stringify(results, null, 2));
  await mongoose.disconnect();
}

main().catch(async (error) => {
  console.error(error);
  await mongoose.disconnect();
  process.exit(1);
});
