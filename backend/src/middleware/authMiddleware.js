const jwt = require("jsonwebtoken");

const protect = (req, res, next) => {
  let token;

  // El token debe venir en el header "Authorization" con el formato "Bearer <token>"
  if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
    try {
      // Extraer solo el token, omitiendo la palabra "Bearer "
      token = req.headers.authorization.split(" ")[1];

      // Decodificar y verificar con nuestro secreto
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Inyectar la información decodificada (que contiene el ID) en req.user
      req.user = decoded;
      
      // Permitir que la petición continúe hacia la ruta final
      next();
    } catch (error) {
      return res.status(401).json({ message: "No autorizado, token fallido o expirado" });
    }
  }

  if (!token) {
    return res.status(401).json({ message: "No autorizado, se requiere token" });
  }
};

module.exports = { protect };