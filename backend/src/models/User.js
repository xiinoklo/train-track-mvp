const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, trim: true, lowercase: true },
    password: { type: String, required: true },
    age: { type: Number },
    gender: { type: String },
    experienceLevel: { type: String, enum: ['principiante', 'intermedio', 'avanzado'] },
    mainGoal: { type: String },
    
    // --- NUEVO: SISTEMA DE VERIFICACIÓN ---
    isVerified: { type: Boolean, default: false },
    verificationCode: { type: String },
    
    // Índice TTL: MongoDB revisará este campo. Si la fecha actual supera este valor,
    // el documento completo será eliminado automáticamente.
    expireAt: { type: Date, expires: 0 } 
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);