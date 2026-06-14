const express = require("express");
const { protect } = require("../middleware/authMiddleware");
const {
  getMuscleRecoveryDetails,
  muscleGroupHierarchy
} = require("../services/muscleRecoveryService");

const router = express.Router();

router.get("/", protect, async (req, res) => {
  try {
    const recovery = await getMuscleRecoveryDetails(req.user.id);

    res.json({
      total: recovery.length,
      recovery,
      groups: muscleGroupHierarchy
    });
  } catch (error) {
    console.error("Error al calcular recuperacion muscular:", error);

    res.status(500).json({
      message: "Error interno al calcular recuperacion muscular"
    });
  }
});

module.exports = router;
