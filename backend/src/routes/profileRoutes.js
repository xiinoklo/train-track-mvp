const express = require("express");
const User = require("../models/User");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

function getRankFromLevel(level) {
  if (level <= 2) return "Principiante";
  if (level <= 4) return "Intermedio";
  return "Avanzado";
}

router.get("/me", protect, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select(
      "-password -verificationCode -expireAt"
    );

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado"
      });
    }

    const currentXp = user.xp || 0;
    const level = user.level || 1;
    const xpGoal = 100;
    const xpInCurrentLevel = currentXp % xpGoal;

    res.json({
      user: {
        id: user._id,
        email: user.email,
        username: user.username,
        avatar: user.avatar,
        xp: currentXp,
        level,
        rank: getRankFromLevel(level),
        xpGoal,
        xpInCurrentLevel,
        age: user.age,
        gender: user.gender,
        experienceLevel: user.experienceLevel,
        mainGoal: user.mainGoal
      }
    });
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener perfil"
    });
  }
});

router.patch("/me", protect, async (req, res) => {
  try {
    const { username, avatar } = req.body;

    const updates = {};

    if (username !== undefined) {
      const cleanUsername = username.trim().toLowerCase();

      if (cleanUsername.length < 3 || cleanUsername.length > 20) {
        return res.status(400).json({
          message: "El username debe tener entre 3 y 20 caracteres"
        });
      }

      if (!/^[a-zA-Z0-9_]+$/.test(cleanUsername)) {
        return res.status(400).json({
          message: "El username solo puede usar letras, números y guion bajo"
        });
      }

      const usernameExists = await User.findOne({
        username: cleanUsername,
        _id: { $ne: req.user.id }
      });

      if (usernameExists) {
        return res.status(400).json({
          message: "Ese username ya está en uso"
        });
      }

      updates.username = cleanUsername;
    }

    if (avatar !== undefined) {
      updates.avatar = avatar;
    }

    const user = await User.findByIdAndUpdate(req.user.id, updates, {
      new: true
    }).select("-password -verificationCode -expireAt");

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado"
      });
    }

    res.json({
      message: "Perfil actualizado correctamente",
      user
    });
  } catch (error) {
    res.status(500).json({
      message: "Error al actualizar perfil"
    });
  }
});

module.exports = router;