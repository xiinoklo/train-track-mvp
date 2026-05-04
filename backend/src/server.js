const dns = require("dns");
const express = require("express");
const cors = require("cors");
const mongoSanitize = require("express-mongo-sanitize");
const connectDB = require("./config/db");

dns.setServers(["8.8.8.8", "1.1.1.1"]);

const authRoutes = require("./routes/authRoutes");
const exerciseRoutes = require("./routes/exerciseRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const wellnessRoutes = require("./routes/wellnessRoutes");
const recoveryRoutes = require("./routes/recoveryRoutes");

connectDB();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());

app.use(express.json({ limit: "10kb" }));

app.use(mongoSanitize());

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
app.use("/api/recovery", recoveryRoutes);

app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});