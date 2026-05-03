const mongoose = require("mongoose");

const wellnessSchema = new mongoose.Schema(
  {
    // Agregamos userId. Por ahora será un String estático o enviado en el body, 
    // pero te prepara para cuando implementes la autenticación real.
    userId: {
      type: String,
      required: [true, "El ID del usuario es obligatorio para registrar su bienestar"]
    },
    sleep: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    pain: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    fatigue: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    stress: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    mood: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    }
  },
  {
    timestamps: true // Esto genera createdAt y updatedAt automáticamente.
  }
);

module.exports = mongoose.model("Wellness", wellnessSchema);