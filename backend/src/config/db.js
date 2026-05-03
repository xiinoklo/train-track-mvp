const mongoose = require("mongoose");
const SystemConfig = require("../models/SystemConfig");
require("dotenv").config();

const seedInitialConfig = async () => {
  try {
    const configCount = await SystemConfig.countDocuments();
    if (configCount === 0) {
      await SystemConfig.create({});
      console.log("[+] Configuración inicial del sistema inyectada.");
    }
    // Ya no inyectamos ejercicios aquí porque ya viven permanentemente en tu base de datos.
  } catch (error) {
    console.error("[ERROR] Fallo al inyectar datos iniciales:", error);
  }
};

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`[+] MongoDB Conectado: ${conn.connection.host}`);
    await seedInitialConfig();
  } catch (error) {
    console.error(`[ERROR] Fallo al conectar a MongoDB: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;