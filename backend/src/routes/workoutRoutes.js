const express = require("express");
const WorkoutSession = require("../models/WorkoutSession");
const Exercise = require("../models/Exercise");

const { calculateLoadFactor } = require("../services/loadEngine");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

// Generar y GUARDAR la sesión
router.post("/generate", protect, async (req, res) => {
  // Simulación de usuario autenticado. Más adelante esto lo sacaremos del token JWT.
  // IMPORTANTE: Asegúrate de tener un usuario creado en tu base de datos y pon su _id aquí para probar, 
  // o usa un string temporal (aunque Mongoose se quejará si no es un ObjectId válido).
  // Para pruebas iniciales, usaremos un ObjectId falso pero válido en formato.
  const userId = req.user.id;
  
  const { sleep, pain, fatigue, stress, mood } = req.body;

  // Lógica de carga
  const result = await calculateLoadFactor({ sleep, pain, fatigue, stress, mood });

  let workoutExercises = [];
  if (result.factor > 0) {
    const sets = result.factor === 1 ? 4 : 2;
    
    // OBTENEMOS LOS EJERCICIOS ACTIVOS DIRECTAMENTE DE LA BASE DE DATOS
    const dbExercises = await Exercise.find({ isActive: true });
    
    workoutExercises = dbExercises.map((exercise) => ({
      exerciseId: exercise._id,
      name: exercise.name,
      sets: sets,
      reps: "10-12",
      videoUrl: exercise.videoUrl,
      instructions: exercise.instructions
    }));
  }

  try {
    // Persistir la sesión en la base de datos
    const newSession = await WorkoutSession.create({
      userId,
      loadFactor: result.factor,
      recommendationLabel: result.label,
      exercises: workoutExercises
    });

    res.status(201).json({
      message: result.message,
      sessionId: newSession._id, // Entregamos el ID de la sesión al frontend
      loadFactor: result.factor,
      recommendation: result.label,
      exercises: workoutExercises
    });
  } catch (error) {
    console.error("Error al guardar la sesión:", error);
    res.status(500).json({ message: "Error interno del servidor" });
  }
});

// Registrar el RPE asociado a una SESIÓN ESPECÍFICA
router.post("/:sessionId/rpe", protect, async (req, res) => {
  const { sessionId } = req.params;
  const { rpe } = req.body;

  if (!rpe || rpe < 1 || rpe > 10) {
    return res.status(400).json({ message: "El RPE debe estar entre 1 y 10" });
  }

  try {
    // Buscamos la sesión y la actualizamos con el RPE y la fecha de completado
    const updatedSession = await WorkoutSession.findByIdAndUpdate(
      sessionId,
      { 
        rpe: rpe,
        completedAt: new Date()
      },
      { new: true } // Devuelve el documento actualizado
    );

    if (!updatedSession) {
      return res.status(404).json({ message: "Sesión de entrenamiento no encontrada" });
    }

    res.json({
      message: "RPE registrado y sesión completada",
      session: updatedSession
    });
  } catch (error) {
    console.error("Error al registrar RPE:", error);
    res.status(500).json({ message: "Error interno al actualizar la sesión" });
  }
});

module.exports = router;