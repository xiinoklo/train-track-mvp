const express = require("express");
const cors = require("cors");
<<<<<<< HEAD
const connectDB = require("./config/db"); // Importa la conexión

const authRoutes = require("./routes/authRoutes");
=======

>>>>>>> 576b4005b62eace3620becba8b991738cb1e630f
const exerciseRoutes = require("./routes/exerciseRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const wellnessRoutes = require("./routes/wellnessRoutes");

<<<<<<< HEAD
// Conectar a Mongoose inmediatamente
connectDB();

const app = express();
const PORT = process.env.PORT || 3000; // Usa el puerto del .env

app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
=======
const app = express();

const PORT = 3000;

app.use(cors());
app.use(express.json());
>>>>>>> 576b4005b62eace3620becba8b991738cb1e630f

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
<<<<<<< HEAD
  console.log(`Servidor corriendo en el puerto ${PORT}`);
=======
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
>>>>>>> 576b4005b62eace3620becba8b991738cb1e630f
});