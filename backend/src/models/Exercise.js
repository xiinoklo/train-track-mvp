const mongoose = require("mongoose");

const exerciseSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    level: { type: String, required: true, enum: ['principiante', 'intermedio', 'avanzado'] },
    muscleGroup: { type: String, required: true },
    description: { type: String, required: true },
    instructions: { type: String, required: true },
    videoUrl: { type: String, required: true },
    isActive: { type: Boolean, default: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Exercise", exerciseSchema);