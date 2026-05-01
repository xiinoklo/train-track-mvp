const express = require("express");
const exercises = require("../data/exercises");

const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    total: exercises.length,
    exercises: exercises
  });
});

module.exports = router;