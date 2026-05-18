const jwt = require("jsonwebtoken");
const User = require("../models/User");

const protect = (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    try {
      token = req.headers.authorization.split(" ")[1];

      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = decoded;

      next();
    } catch (error) {
      return res.status(401).json({
        message: "No autorizado, token fallido o expirado"
      });
    }
  }

  if (!token) {
    return res.status(401).json({
      message: "No autorizado, se requiere token"
    });
  }
};

const requireAdmin = async (req, res, next) => {
  try {
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        message: "No autorizado"
      });
    }

    const user = await User.findById(req.user.id).select("role email");

    if (!user) {
      return res.status(404).json({
        message: "Usuario no encontrado"
      });
    }

    if (user.role !== "admin") {
      return res.status(403).json({
        message: "Acceso denegado. Se requiere rol administrador"
      });
    }

    req.admin = user;

    next();
  } catch (error) {
    return res.status(500).json({
      message: "Error validando permisos de administrador"
    });
  }
};

module.exports = { protect, requireAdmin };