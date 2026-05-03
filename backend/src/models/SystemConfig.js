const mongoose = require("mongoose");

const systemConfigSchema = new mongoose.Schema(
  {
    // Umbrales para forzar Descanso (Factor 0)
    restThresholds: {
      pain: { type: Number, default: 4 },
      fatigue: { type: Number, default: 5 }
    },
    // Umbrales para forzar Sesión Reducida (Factor 0.5)
    reducedThresholds: {
      sleep: { type: Number, default: 2 },
      stress: { type: Number, default: 4 },
      fatigue: { type: Number, default: 4 },
      mood: { type: Number, default: 2 }
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model("SystemConfig", systemConfigSchema);