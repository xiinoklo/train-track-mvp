const express = require("express");
const Wellness = require("../models/Wellness"); // Importar el modelo

const router = express.Router();
const { protect } = require("../middleware/authMiddleware");

// Ruta POST para registrar el bienestar
router.post("/", protect, async (req, res) => {
  const userId = req.user.id;
  const { sleep, pain, fatigue, stress, mood } = req.body;

  if (
    !sleep || !pain || !fatigue || !stress || !mood ||
    sleep < 1 || sleep > 5 || pain < 1 || pain > 5 ||
    fatigue < 1 || fatigue > 5 || stress < 1 || stress > 5 ||
    mood < 1 || mood > 5
  ) {
    return res.status(400).json({
      message: "Todos los valores de bienestar deben estar entre 1 y 5"
    });
  }

  try {
    // Crear el registro en MongoDB
    const wellnessEntry = await Wellness.create({
      userId,
      sleep,
      pain,
      fatigue,
      stress,
      mood
    });

    console.log("Bienestar registrado en DB:", wellnessEntry._id);

    res.status(201).json({
      message: "Bienestar registrado correctamente",
      wellness: wellnessEntry
    });
  } catch (error) {
    console.error("Error guardando en DB:", error);
    res.status(500).json({ message: "Error interno del servidor", error: error.message });
  }
});

// Ruta GET para obtener el historial
router.get("/", protect, async (req, res) => {
  try {
    // Obtiene todos los registros de la base de datos
    const wellnessEntries = await Wellness.find({ userId: req.user.id }).sort({ createdAt: -1 });

    res.json({
      total: wellnessEntries.length,
      wellnessEntries: wellnessEntries
    });
  } catch (error) {
    console.error("Error consultando la DB:", error);
    res.status(500).json({ message: "Error interno del servidor" });
  }
});

module.exports = router;