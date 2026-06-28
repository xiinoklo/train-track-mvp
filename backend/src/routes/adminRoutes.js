const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");

const User = require("../models/User");
const Wellness = require("../models/Wellness");
const WorkoutSession = require("../models/WorkoutSession");
const Exercise = require("../models/Exercise");
const SavedRoutine = require("../models/SavedRoutine");
const AccessLog = require("../models/AccessLog");

const { recordAccess } = require("../services/accessLogService");
const { protect, requireAdmin } = require("../middleware/authMiddleware");

const router = express.Router();
const ANALYTICS_TIMEZONE = "America/Santiago";

const dayLabels = {
  1: "Domingo",
  2: "Lunes",
  3: "Martes",
  4: "Miercoles",
  5: "Jueves",
  6: "Viernes",
  7: "Sabado"
};

const moodLabels = {
  1: "Muy bajo",
  2: "Bajo",
  3: "Neutro",
  4: "Bueno",
  5: "Excelente"
};

function percent(count, total) {
  if (!total) return 0;
  return Math.round((count / total) * 1000) / 10;
}

function countMap(items) {
  return new Map(items.map((item) => [Number(item._id), item.count]));
}

function seriesFromRange({ items, min, max, labelFor, keyName, total }) {
  const map = countMap(items);
  return Array.from({ length: max - min + 1 }, (_, index) => {
    const key = min + index;
    const count = map.get(key) || 0;

    return {
      [keyName]: key,
      label: labelFor(key),
      count,
      percentage: percent(count, total)
    };
  });
}

function isValidVideoUrl(value) {
  const videoUrl = String(value || "").trim();

  if (!videoUrl) return true;

  return /^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtube\.com\/shorts\/|youtu\.be\/)/i.test(
    videoUrl
  );
}

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Email y contraseña son obligatorios"
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase().trim()
    });

    if (!user) {
      return res.status(400).json({
        message: "Credenciales inválidas"
      });
    }

    if (!user.isVerified) {
      return res.status(403).json({
        message: "Cuenta admin no verificada"
      });
    }

    if (user.role !== "admin") {
      return res.status(403).json({
        message: "Este usuario no tiene permisos de administrador"
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Credenciales inválidas"
      });
    }

    const token = jwt.sign(
      {
        id: user._id,
        role: user.role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "30d"
      }
    );

    await recordAccess({ req, user, type: "admin_login" });

    res.json({
      token,
      user: {
        id: user._id,
        email: user.email,
        username: user.username,
        role: user.role
      }
    });
  } catch (error) {
    console.error("Error en login admin:", error);

    res.status(500).json({
      message: "Error interno en login admin"
    });
  }
});

router.get("/users", protect, requireAdmin, async (req, res) => {
  try {
    const users = await User.find()
      .select("-password -verificationCode -expireAt")
      .sort({ createdAt: -1 })
      .lean();
    const userIds = users.map((user) => user._id);
    const sessionCounts = await WorkoutSession.aggregate([
      { $match: { userId: { $in: userIds } } },
      { $group: { _id: "$userId", count: { $sum: 1 } } }
    ]);
    const savedCounts = await SavedRoutine.aggregate([
      { $match: { userId: { $in: userIds } } },
      { $group: { _id: "$userId", count: { $sum: 1 } } }
    ]);
    const accessStats = await AccessLog.aggregate([
      { $match: { userId: { $in: userIds } } },
      { $sort: { createdAt: -1 } },
      {
        $group: {
          _id: "$userId",
          count: { $sum: 1 },
          lastAccessAt: { $first: "$createdAt" },
          lastAccessType: { $first: "$type" }
        }
      }
    ]);
    const countMap = new Map(
      sessionCounts.map((item) => [item._id.toString(), item.count])
    );
    const savedCountMap = new Map(
      savedCounts.map((item) => [item._id.toString(), item.count])
    );
    const accessStatsMap = new Map(
      accessStats.map((item) => [item._id.toString(), item])
    );
    const usersWithRoutines = users.map((user) => ({
      ...user,
      workoutCount: countMap.get(user._id.toString()) || 0,
      savedRoutineCount: savedCountMap.get(user._id.toString()) || 0,
      accessCount: accessStatsMap.get(user._id.toString())?.count || 0,
      lastAccessAt:
        accessStatsMap.get(user._id.toString())?.lastAccessAt || null,
      lastAccessType:
        accessStatsMap.get(user._id.toString())?.lastAccessType || null
    }));

    res.json({
      total: usersWithRoutines.length,
      users: usersWithRoutines
    });
  } catch (error) {
    console.error("Error obteniendo usuarios admin:", error);

    res.status(500).json({
      message: "Error al obtener usuarios"
    });
  }
});

router.get("/stats", protect, requireAdmin, async (req, res) => {
  try {
    const completedSessionMatch = {
      completedAt: { $ne: null, $exists: true }
    };
    const [
      totalUsers,
      completedWorkoutSessions,
      usersPerRank,
      topExercises,
      commonExerciseDays,
      weeklyTrainingDays,
      rpeFrequency,
      preWorkoutMood
    ] = await Promise.all([
      User.countDocuments(),
      WorkoutSession.countDocuments(completedSessionMatch),
      User.aggregate([
        { $group: { _id: "$level", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        { $unwind: "$exercises" },
        {
          $group: {
            _id: { id: "$exercises.exerciseId", name: "$exercises.name" },
            count: { $sum: 1 }
          }
        },
        { $sort: { count: -1 } },
        { $limit: 5 },
        {
          $project: {
            _id: 0,
            exerciseId: "$_id.id",
            name: "$_id.name",
            count: 1
          }
        }
      ]),
      WorkoutSession.aggregate([
        { $match: completedSessionMatch },
        {
          $project: {
            dayOfWeek: {
              $dayOfWeek: {
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            }
          }
        },
        { $group: { _id: "$dayOfWeek", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        { $match: completedSessionMatch },
        {
          $project: {
            userId: 1,
            isoYear: {
              $isoWeekYear: {
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            },
            isoWeek: {
              $isoWeek: {
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            },
            dayKey: {
              $dateToString: {
                format: "%Y-%m-%d",
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            }
          }
        },
        {
          $group: {
            _id: {
              userId: "$userId",
              isoYear: "$isoYear",
              isoWeek: "$isoWeek"
            },
            days: { $addToSet: "$dayKey" }
          }
        },
        {
          $project: {
            _id: 0,
            daysPerWeek: { $size: "$days" }
          }
        },
        { $group: { _id: "$daysPerWeek", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        {
          $match: {
            ...completedSessionMatch,
            rpe: { $gte: 1, $lte: 10 }
          }
        },
        { $group: { _id: "$rpe", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        { $match: completedSessionMatch },
        {
          $lookup: {
            from: Wellness.collection.name,
            let: {
              sessionUserId: { $toString: "$userId" },
              sessionCreatedAt: "$createdAt"
            },
            pipeline: [
              {
                $match: {
                  $expr: {
                    $and: [
                      { $eq: ["$userId", "$$sessionUserId"] },
                      { $lte: ["$createdAt", "$$sessionCreatedAt"] }
                    ]
                  }
                }
              },
              { $sort: { createdAt: -1 } },
              { $limit: 1 },
              { $project: { mood: 1 } }
            ],
            as: "preWorkoutWellness"
          }
        },
        { $unwind: "$preWorkoutWellness" },
        { $group: { _id: "$preWorkoutWellness.mood", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ])
    ]);
    const totalUserWeeks = weeklyTrainingDays.reduce(
      (total, item) => total + item.count,
      0
    );
    const totalRpeAnswers = rpeFrequency.reduce(
      (total, item) => total + item.count,
      0
    );
    const totalMoodMatches = preWorkoutMood.reduce(
      (total, item) => total + item.count,
      0
    );

    res.json({
      totalUsers,
      usersPerRank,
      topExercises,
      commonExerciseDays: seriesFromRange({
        items: commonExerciseDays,
        min: 1,
        max: 7,
        keyName: "dayOfWeek",
        labelFor: (key) => dayLabels[key],
        total: completedWorkoutSessions
      }),
      weeklyDayFrequency: seriesFromRange({
        items: weeklyTrainingDays,
        min: 1,
        max: 7,
        keyName: "daysPerWeek",
        labelFor: (key) => `${key} ${key === 1 ? "dia" : "dias"}`,
        total: totalUserWeeks
      }),
      rpeFrequency: seriesFromRange({
        items: rpeFrequency,
        min: 1,
        max: 10,
        keyName: "rpe",
        labelFor: (key) => `RPE ${key}`,
        total: totalRpeAnswers
      }),
      preWorkoutMood: seriesFromRange({
        items: preWorkoutMood,
        min: 1,
        max: 5,
        keyName: "mood",
        labelFor: (key) => moodLabels[key],
        total: totalMoodMatches
      })
    });
  } catch (error) {
    console.error("Error obteniendo estadisticas admin:", error);
    res.status(500).json({
      message: "Error al obtener estadisticas"
    });
  }
});

router.get("/users/:id/stats", protect, requireAdmin, async (req, res) => {
  try {
    const userObjectId = new mongoose.Types.ObjectId(req.params.id);
    const user = await User.findById(req.params.id).select("level xp");

    if (!user) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }

    const completedSessionMatch = {
      userId: userObjectId,
      completedAt: { $ne: null, $exists: true }
    };
    const [
      completedWorkoutSessions,
      topExercises,
      commonExerciseDays,
      weeklyTrainingDays,
      rpeFrequency,
      preWorkoutMood
    ] = await Promise.all([
      WorkoutSession.countDocuments(completedSessionMatch),
      WorkoutSession.aggregate([
        { $match: { userId: userObjectId } },
        { $unwind: "$exercises" },
        {
          $group: {
            _id: { id: "$exercises.exerciseId", name: "$exercises.name" },
            count: { $sum: 1 }
          }
        },
        { $sort: { count: -1 } },
        { $limit: 5 },
        {
          $project: {
            _id: 0,
            exerciseId: "$_id.id",
            name: "$_id.name",
            count: 1
          }
        }
      ]),
      WorkoutSession.aggregate([
        { $match: completedSessionMatch },
        {
          $project: {
            dayOfWeek: {
              $dayOfWeek: {
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            }
          }
        },
        { $group: { _id: "$dayOfWeek", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        { $match: completedSessionMatch },
        {
          $project: {
            isoYear: {
              $isoWeekYear: {
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            },
            isoWeek: {
              $isoWeek: {
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            },
            dayKey: {
              $dateToString: {
                format: "%Y-%m-%d",
                date: "$completedAt",
                timezone: ANALYTICS_TIMEZONE
              }
            }
          }
        },
        {
          $group: {
            _id: {
              isoYear: "$isoYear",
              isoWeek: "$isoWeek"
            },
            days: { $addToSet: "$dayKey" }
          }
        },
        {
          $project: {
            _id: 0,
            daysPerWeek: { $size: "$days" }
          }
        },
        { $group: { _id: "$daysPerWeek", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        {
          $match: {
            ...completedSessionMatch,
            rpe: { $gte: 1, $lte: 10 }
          }
        },
        { $group: { _id: "$rpe", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ]),
      WorkoutSession.aggregate([
        { $match: completedSessionMatch },
        {
          $lookup: {
            from: Wellness.collection.name,
            let: {
              sessionCreatedAt: "$createdAt"
            },
            pipeline: [
              {
                $match: {
                  $expr: {
                    $and: [
                      { $eq: ["$userId", req.params.id] },
                      { $lte: ["$createdAt", "$$sessionCreatedAt"] }
                    ]
                  }
                }
              },
              { $sort: { createdAt: -1 } },
              { $limit: 1 },
              { $project: { mood: 1 } }
            ],
            as: "preWorkoutWellness"
          }
        },
        { $unwind: "$preWorkoutWellness" },
        { $group: { _id: "$preWorkoutWellness.mood", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ])
    ]);
    const totalUserWeeks = weeklyTrainingDays.reduce(
      (total, item) => total + item.count,
      0
    );
    const totalRpeAnswers = rpeFrequency.reduce(
      (total, item) => total + item.count,
      0
    );
    const totalMoodMatches = preWorkoutMood.reduce(
      (total, item) => total + item.count,
      0
    );

    res.json({
      level: user.level,
      xp: user.xp,
      topExercises,
      commonExerciseDays: seriesFromRange({
        items: commonExerciseDays,
        min: 1,
        max: 7,
        keyName: "dayOfWeek",
        labelFor: (key) => dayLabels[key],
        total: completedWorkoutSessions
      }),
      weeklyDayFrequency: seriesFromRange({
        items: weeklyTrainingDays,
        min: 1,
        max: 7,
        keyName: "daysPerWeek",
        labelFor: (key) => `${key} ${key === 1 ? "dia" : "dias"}`,
        total: totalUserWeeks
      }),
      rpeFrequency: seriesFromRange({
        items: rpeFrequency,
        min: 1,
        max: 10,
        keyName: "rpe",
        labelFor: (key) => `RPE ${key}`,
        total: totalRpeAnswers
      }),
      preWorkoutMood: seriesFromRange({
        items: preWorkoutMood,
        min: 1,
        max: 5,
        keyName: "mood",
        labelFor: (key) => moodLabels[key],
        total: totalMoodMatches
      })
    });
  } catch (error) {
    console.error("Error obteniendo estadisticas de usuario:", error);
    res.status(500).json({
      message: "Error al obtener estadisticas de usuario"
    });
  }
});

router.delete("/users/:id", protect, requireAdmin, async (req, res) => {
  try {
    const userId = req.params.id;

    if (userId === req.user.id) {
      return res.status(400).json({
        message: "No puedes eliminar tu propio usuario admin"
      });
    }

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado"
      });
    }

    await Wellness.deleteMany({
      userId: userId
    });

    await WorkoutSession.deleteMany({
      userId: userId
    });

    await SavedRoutine.deleteMany({
      userId: userId
    });

    await AccessLog.deleteMany({
      userId: userId
    });

    await User.findByIdAndDelete(userId);

    res.json({
      message: "Usuario y datos asociados eliminados correctamente",
      deletedUserId: userId
    });
  } catch (error) {
    console.error("Error eliminando usuario admin:", error);

    res.status(500).json({
      message: "Error al eliminar usuario"
    });
  }
});

router.get("/users/:id/routines", protect, requireAdmin, async (req, res) => {
  try {
    const savedRoutines = await SavedRoutine.find({ userId: req.params.id })
      .sort({ createdAt: -1 })
      .lean();

    res.json({ sessions: [], savedRoutines });
  } catch (error) {
    res.status(500).json({ message: "Error al obtener rutinas del usuario" });
  }
});

router.delete("/routines/:type/:id", protect, requireAdmin, async (req, res) => {
  try {
    if (req.params.type !== "saved") {
      return res.status(400).json({
        message: "Solo se pueden eliminar rutinas creadas"
      });
    }

    const routine = await SavedRoutine.findByIdAndDelete(req.params.id);

    if (!routine) {
      return res.status(404).json({ message: "Rutina no encontrada" });
    }

    res.json({ message: "Rutina eliminada correctamente" });
  } catch (error) {
    res.status(500).json({ message: "Error al eliminar rutina" });
  }
});

router.get("/exercises", protect, requireAdmin, async (req, res) => {
  try {
    const exercises = await Exercise.find().sort({ createdAt: -1 });

    res.json({
      total: exercises.length,
      exercises
    });
  } catch (error) {
    console.error("Error obteniendo ejercicios admin:", error);

    res.status(500).json({
      message: "Error al obtener ejercicios"
    });
  }
});

router.post("/exercises", protect, requireAdmin, async (req, res) => {
  try {
    const {
      name,
      level,
      muscleGroup,
      description,
      instructions,
      videoUrl,
      xp,
      isActive
    } = req.body;

    if (!name || !muscleGroup) {
      return res.status(400).json({
        message: "Nombre y grupo muscular son obligatorios"
      });
    }

    if (!isValidVideoUrl(videoUrl)) {
      return res.status(400).json({
        message: "La URL del video debe ser de YouTube"
      });
    }

    const exercise = await Exercise.create({
      name,
      level: level || "principiante",
      muscleGroup,
      description: description || name,
      instructions: instructions || description || "Sin instrucciones",
      videoUrl: videoUrl || "",
      xp: Number.isFinite(Number(xp)) ? Number(xp) : 10,
      isActive: isActive !== false
    });

    res.status(201).json({
      message: "Ejercicio creado correctamente",
      exercise
    });
  } catch (error) {
    console.error("Error creando ejercicio admin:", error);

    res.status(400).json({
      message: "Error al crear ejercicio",
      error: error.message
    });
  }
});

router.put("/exercises/:id", protect, requireAdmin, async (req, res) => {
  try {
    const exerciseId = req.params.id;

    const allowedFields = [
      "name",
      "level",
      "muscleGroup",
      "description",
      "instructions",
      "videoUrl",
      "xp",
      "isActive"
    ];

    const updates = {};

    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    if (
      updates.videoUrl !== undefined &&
      !isValidVideoUrl(updates.videoUrl)
    ) {
      return res.status(400).json({
        message: "La URL del video debe ser de YouTube"
      });
    }

    const exercise = await Exercise.findByIdAndUpdate(
      exerciseId,
      updates,
      {
        new: true,
        runValidators: true
      }
    );

    if (!exercise) {
      return res.status(404).json({
        message: "Ejercicio no encontrado"
      });
    }

    res.json({
      message: "Ejercicio actualizado correctamente",
      exercise
    });
  } catch (error) {
    console.error("Error actualizando ejercicio admin:", error);

    res.status(400).json({
      message: "Error al actualizar ejercicio",
      error: error.message
    });
  }
});

router.delete("/exercises/:id", protect, requireAdmin, async (req, res) => {
  try {
    const exercise = await Exercise.findByIdAndDelete(req.params.id);

    if (!exercise) {
      return res.status(404).json({
        message: "Ejercicio no encontrado"
      });
    }

    res.json({
      message: "Ejercicio eliminado correctamente",
      deletedExerciseId: req.params.id
    });
  } catch (error) {
    console.error("Error eliminando ejercicio admin:", error);

    res.status(500).json({
      message: "Error al eliminar ejercicio"
    });
  }
});

module.exports = router;
