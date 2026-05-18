const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const rateLimit = require("express-rate-limit");
const User = require("../models/User");
const { sendVerificationEmail } = require("../services/emailService");

const router = express.Router();

const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 3,
  message: { message: "Límite de registros alcanzado." }
});

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: { message: "Demasiados intentos. Bloqueado." }
});

// POST /api/auth/register
router.post("/register", registerLimiter, async (req, res) => {
  try {
    const { email, password, age, gender, experienceLevel, mainGoal } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Email y contraseña son obligatorios"
      });
    }

    const cleanEmail = email.toLowerCase().trim();

    let userExists = await User.findOne({ email: cleanEmail });

    if (userExists && userExists.isVerified) {
      return res.status(400).json({
        message: "El usuario ya está registrado y activo"
      });
    } else if (userExists) {
      await User.deleteOne({ email: cleanEmail });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expirationDate = new Date(Date.now() + 10 * 60 * 1000);

    const user = await User.create({
      email: cleanEmail,
      password: hashedPassword,
      age,
      gender,
      experienceLevel,
      mainGoal,
      role: "user",
      isVerified: false,
      verificationCode: code,
      expireAt: expirationDate
    });

    const emailSent = await sendVerificationEmail(cleanEmail, code);

    if (!emailSent) {
      await User.findByIdAndDelete(user._id);

      return res.status(500).json({
        message: "Error al enviar el correo. Intenta usar otro email."
      });
    }

    res.status(201).json({
      message: "Código de verificación enviado al correo."
    });
  } catch (error) {
    res.status(500).json({
      message: "Error en el servidor",
      error: error.message
    });
  }
});

// POST /api/auth/verify
router.post("/verify", async (req, res) => {
  try {
    const { email, code } = req.body;

    const cleanEmail = email.toLowerCase().trim();

    const user = await User.findOne({ email: cleanEmail });

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado o el código expiró."
      });
    }

    if (user.isVerified) {
      return res.status(400).json({
        message: "La cuenta ya está verificada."
      });
    }

    if (user.verificationCode !== code) {
      return res.status(400).json({
        message: "Código incorrecto."
      });
    }

    user.isVerified = true;
    user.verificationCode = undefined;
    user.expireAt = undefined;

    await user.save();

    const role = user.role || "user";
    const isAdmin = role === "admin";

    const token = jwt.sign(
      {
        id: user._id,
        role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "30d"
      }
    );

    res.json({
      token,
      userId: user._id,
      email: user.email,
      role,
      isAdmin,
      message: "Cuenta activada con éxito."
    });
  } catch (error) {
    res.status(500).json({
      message: "Error en el servidor"
    });
  }
});

// POST /api/auth/login
router.post("/login", loginLimiter, async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Email y contraseña son obligatorios"
      });
    }

    const cleanEmail = email.toLowerCase().trim();

    const user = await User.findOne({ email: cleanEmail });

    if (!user) {
      return res.status(400).json({
        message: "Credenciales inválidas"
      });
    }

    if (!user.isVerified) {
      return res.status(403).json({
        message:
          "Cuenta no verificada. Por favor regístrate de nuevo si el código expiró."
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Credenciales inválidas"
      });
    }

    const role = user.role || "user";
    const isAdmin = role === "admin";

    const token = jwt.sign(
      {
        id: user._id,
        role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "30d"
      }
    );

    res.json({
      token,
      userId: user._id,
      email: user.email,
      role,
      isAdmin
    });
  } catch (error) {
    res.status(500).json({
      message: "Error en el servidor"
    });
  }
});

module.exports = router;