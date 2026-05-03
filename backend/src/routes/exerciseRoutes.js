const express = require("express");
<<<<<<< HEAD
const Exercise = require("../models/Exercise");

const router = express.Router();

// GET: Obtener todos los ejercicios activos (Para el usuario)
router.get("/", async (req, res) => {
  try {
    const exercises = await Exercise.find({ isActive: true });
    res.json({ total: exercises.length, exercises });
  } catch (error) {
    res.status(500).json({ message: "Error al obtener ejercicios" });
  }
});

// GET: Obtener TODOS los ejercicios (Para el Administrador)
router.get("/admin", async (req, res) => {
  try {
    const exercises = await Exercise.find();
    res.json({ total: exercises.length, exercises });
  } catch (error) {
    res.status(500).json({ message: "Error al obtener catálogo" });
  }
});

// POST: Crear un nuevo ejercicio (Administrador)
router.post("/", async (req, res) => {
  try {
    const newExercise = await Exercise.create(req.body);
    res.status(201).json(newExercise);
  } catch (error) {
    res.status(400).json({ message: "Error al crear ejercicio", error: error.message });
  }
});

// PUT: Actualizar un ejercicio existente (Administrador)
router.put("/:id", async (req, res) => {
  try {
    const updated = await Exercise.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updated) return res.status(404).json({ message: "Ejercicio no encontrado" });
    res.json(updated);
  } catch (error) {
    res.status(400).json({ message: "Error al actualizar", error: error.message });
  }
=======
const exercises = require("../data/exercises");

const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    total: exercises.length,
    exercises: exercises
  });
>>>>>>> 576b4005b62eace3620becba8b991738cb1e630f
});

module.exports = router;