const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const User = require("../models/User");
const Wellness = require("../models/Wellness");
const WorkoutSession = require("../models/WorkoutSession");
const Exercise = require("../models/Exercise");
const SavedRoutine = require("../models/SavedRoutine");

const { protect, requireAdmin } = require("../middleware/authMiddleware");

const router = express.Router();

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
    const countMap = new Map(
      sessionCounts.map((item) => [item._id.toString(), item.count])
    );
    const savedCountMap = new Map(
      savedCounts.map((item) => [item._id.toString(), item.count])
    );
    const usersWithRoutines = users.map((user) => ({
      ...user,
      workoutCount: countMap.get(user._id.toString()) || 0,
      savedRoutineCount: savedCountMap.get(user._id.toString()) || 0
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
    const [sessions, savedRoutines] = await Promise.all([
      WorkoutSession.find({ userId: req.params.id })
        .sort({ createdAt: -1 })
        .lean(),
      SavedRoutine.find({ userId: req.params.id })
        .sort({ createdAt: -1 })
        .lean()
    ]);

    res.json({ sessions, savedRoutines });
  } catch (error) {
    res.status(500).json({ message: "Error al obtener rutinas del usuario" });
  }
});

router.delete("/routines/:type/:id", protect, requireAdmin, async (req, res) => {
  try {
    const model = req.params.type === "saved" ? SavedRoutine : WorkoutSession;
    const routine = await model.findByIdAndDelete(req.params.id);

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
