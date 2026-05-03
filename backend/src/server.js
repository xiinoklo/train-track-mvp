const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db"); // Importa la conexión

const authRoutes = require("./routes/authRoutes");
const exerciseRoutes = require("./routes/exerciseRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const wellnessRoutes = require("./routes/wellnessRoutes");

// Conectar a Mongoose inmediatamente
connectDB();

const app = express();
const PORT = process.env.PORT || 3000; // Usa el puerto del .env

app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    app: "TrainTrack API"
  });
});

app.use("/api/exercises", exerciseRoutes);
app.use("/api/workouts", workoutRoutes);
app.use("/api/wellness", wellnessRoutes);

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});