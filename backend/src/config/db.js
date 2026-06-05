const mongoose = require("mongoose");
const SystemConfig = require("../models/SystemConfig");
const Exercise = require("../models/Exercise");
const exercises = require("../data/exercises");
require("dotenv").config();

const seedInitialData = async () => {
  try {
    const configCount = await SystemConfig.countDocuments();

    if (configCount === 0) {
      await SystemConfig.create({});
      console.log("[+] Configuracion inicial del sistema inyectada.");
    }

    let upsertedExercises = 0;

    for (const exercise of exercises) {
      const result = await Exercise.updateOne(
        { name: exercise.name },
        { $setOnInsert: exercise },
        { upsert: true }
      );

      if (result.upsertedCount > 0) {
        upsertedExercises += 1;
      }
    }

    if (upsertedExercises > 0) {
      console.log(`[+] ${upsertedExercises} ejercicios nuevos inyectados.`);
    }
  } catch (error) {
    console.error("[ERROR] Fallo al inyectar datos iniciales:", error);
  }
};

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`[+] MongoDB Conectado: ${conn.connection.host}`);
    await seedInitialData();
  } catch (error) {
    console.error(`[ERROR] Fallo al conectar a MongoDB: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
