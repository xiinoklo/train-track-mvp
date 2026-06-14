const mongoose = require("mongoose");

const savedRoutineSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true
    },
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 60
    },
    exercises: [
      {
        exerciseId: String,
        name: {
          type: String,
          required: true
        },
        muscleGroup: String,
        sets: {
          type: Number,
          min: 1,
          max: 8,
          default: 3
        },
        reps: String,
        weight: String,
        videoUrl: String,
        instructions: String,
        xp: {
          type: Number,
          default: 10
        }
      }
    ]
  },
  { timestamps: true }
);

module.exports = mongoose.model("SavedRoutine", savedRoutineSchema);
