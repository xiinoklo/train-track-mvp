const AccessLog = require("../models/AccessLog");

function getRequestIp(req) {
  const forwardedFor = req.headers["x-forwarded-for"];

  if (typeof forwardedFor === "string" && forwardedFor.trim()) {
    return forwardedFor.split(",")[0].trim();
  }

  return req.ip || req.socket?.remoteAddress || "";
}

async function recordAccess({ req, user, type }) {
  if (!user?._id) return;

  try {
    await AccessLog.create({
      userId: user._id,
      email: user.email,
      role: user.role || "user",
      type,
      ip: getRequestIp(req),
      userAgent: req.get("user-agent") || ""
    });
  } catch (error) {
    console.error("Error registrando acceso:", error);
  }
}

module.exports = {
  recordAccess
};
