const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true
    },
    password: {
      type: String,
      required: true
    },
    username: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
      lowercase: true,
      minlength: 3,
      maxlength: 20,
      match: /^[a-zA-Z0-9_]+$/
    },
    avatar: {
      type: String,
      default: "avatar1"
    },
    xp: {
      type: Number,
      default: 0
    },
    level: {
      type: Number,
      default: 1
    },
    age: {
      type: Number
    },
    gender: {
      type: String
    },
    experienceLevel: {
      type: String,
      enum: ["principiante", "intermedio", "avanzado"]
    },
    mainGoal: {
      type: String
    },

    isVerified: {
      type: Boolean,
      default: false
    },
    verificationCode: {
      type: String
    },
    expireAt: {
      type: Date,
      expires: 0
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);