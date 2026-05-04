const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const rateLimit = require("express-rate-limit");
const User = require("../models/User");
const { sendVerificationEmail } = require("../services/emailService");

const router = express.Router();

const registerLimiter = rateLimit({ windowMs: 60 * 60 * 1000, max: 3, message: { message: "Límite de registros alcanzado." } });
const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 5, message: { message: "Demasiados intentos. Bloqueado." } });

// 1. POST /api/auth/register (Genera el usuario bloqueado y envía correo)
router.post("/register", registerLimiter, async (req, res) => {
  try {
    const { email, password, age, gender, experienceLevel, mainGoal } = req.body;

    if (!email || !password) return res.status(400).json({ message: "Email y contraseña son obligatorios" });

    // Verificar si el usuario ya existe
    let userExists = await User.findOne({ email });

    // Si existe y ya está verificado, rechazar. Si no está verificado, lo dejamos sobrescribir para reenviar el código.
    if (userExists && userExists.isVerified) {
      return res.status(400).json({ message: "El usuario ya está registrado y activo" });
    } else if (userExists) {
      await User.deleteOne({ email }); // Borramos la cuenta inactiva anterior para crearla fresca
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generar código de 6 dígitos
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    // Programar la autodestrucción (10 minutos desde ahora)
    const expirationDate = new Date(Date.now() + 10 * 60 * 1000); 

    const user = await User.create({
      email,
      password: hashedPassword,
      age, gender, experienceLevel, mainGoal,
      isVerified: false,
      verificationCode: code,
      expireAt: expirationDate 
    });

    const emailSent = await sendVerificationEmail(email, code);

    if (!emailSent) {
      // Si el correo falla, borramos al usuario para no dejar basura
      await User.findByIdAndDelete(user._id);
      return res.status(500).json({ message: "Error al enviar el correo. Intenta usar otro email." });
    }

    res.status(201).json({ message: "Código de verificación enviado al correo." });
  } catch (error) {
    res.status(500).json({ message: "Error en el servidor", error: error.message });
  }
});

// 2. POST /api/auth/verify (Valida el código, desactiva la bomba y entrega el Token)
router.post("/verify", async (req, res) => {
  try {
    const { email, code } = req.body;

    const user = await User.findOne({ email });

    if (!user) return res.status(404).json({ message: "Usuario no encontrado o el código expiró." });
    if (user.isVerified) return res.status(400).json({ message: "La cuenta ya está verificada." });
    if (user.verificationCode !== code) return res.status(400).json({ message: "Código incorrecto." });

    // DESARMAR LA BOMBA: Marcamos verificado y eliminamos los campos temporales y el TTL
    user.isVerified = true;
    user.verificationCode = undefined;
    user.expireAt = undefined; 
    await user.save();

    // Generar el pase VIP (JWT)
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "30d" });

    res.json({ token, userId: user._id, email: user.email, message: "Cuenta activada con éxito." });
  } catch (error) {
    res.status(500).json({ message: "Error en el servidor" });
  }
});

// 3. POST /api/auth/login (Bloquea a los no verificados)
router.post("/login", loginLimiter, async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });

    if (!user) return res.status(400).json({ message: "Credenciales inválidas" });
    if (!user.isVerified) return res.status(403).json({ message: "Cuenta no verificada. Por favor regístrate de nuevo si el código expiró." });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Credenciales inválidas" });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "30d" });

    res.json({ token, userId: user._id, email: user.email });
  } catch (error) {
    res.status(500).json({ message: "Error en el servidor" });
  }
});

module.exports = router;