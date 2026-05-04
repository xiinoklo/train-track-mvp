const mongoose = require("mongoose");

const workoutSessionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    loadFactor: {
      type: Number,
      required: true
    },
    recommendationLabel: {
      type: String,
      required: true
    },
    exercises: [
      {
        exerciseId: String,
        name: String,
        sets: Number,
        reps: String
      }
    ],
    // El RPE empieza nulo hasta que el usuario termina la sesión (RF-08)
    rpe: {
      type: Number,
      min: 1,
      max: 10,
      default: null 
    },
    completedAt: {
      type: Date,
      default: null
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model("WorkoutSession", workoutSessionSchema);