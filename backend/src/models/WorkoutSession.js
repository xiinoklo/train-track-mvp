const mongoose = require("mongoose");

const workoutSessionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    targetMuscleGroup: {
      type: String,
      default: "full_body"
    },
    trainedMuscleGroups: [
      {
        type: String
      }
    ],
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
        muscleGroup: String,
        sets: Number,
        reps: String,
        videoUrl: String,
        instructions: String
      }
    ],
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