<<<<<<< HEAD
const SystemConfig = require("../models/SystemConfig");

// ¡Atención! La función ahora es ASYNC
async function calculateLoadFactor({ sleep, pain, fatigue, stress, mood }) {
  try {
    // 1. Obtener la configuración dinámica de la BD
    const config = await SystemConfig.findOne();
    
    if (!config) {
        throw new Error("No se encontró configuración del sistema en la BD");
    }

    const { restThresholds, reducedThresholds } = config;

    // 2. Aplicar las reglas usando los parámetros dinámicos (No quemados)
    if (pain >= restThresholds.pain || fatigue >= restThresholds.fatigue) {
      return {
        factor: 0,
        label: "Descanso recomendado",
        message: "Hoy se recomienda descanso o movilidad suave por dolor o fatiga alta."
      };
    }

    if (
      sleep <= reducedThresholds.sleep || 
      stress >= reducedThresholds.stress || 
      fatigue >= reducedThresholds.fatigue || 
      mood <= reducedThresholds.mood
    ) {
      return {
        factor: 0.5,
        label: "Sesión reducida",
        message: "Hoy se recomienda reducir volumen e intensidad."
      };
    }

    return {
      factor: 1,
      label: "Sesión normal",
      message: "Estado favorable para realizar la sesión planificada."
    };

  } catch (error) {
    console.error("Error en motor de carga:", error);
    // Fallback de seguridad: si falla la BD, recomendamos reducir carga por precaución
    return {
        factor: 0.5,
        label: "Modo seguro (Sesión reducida)",
        message: "No pudimos validar tu carga óptima. Recomendamos entrenamiento suave."
    };
  }
=======
function calculateLoadFactor({ sleep, pain, fatigue, stress, mood }) {
  if (pain >= 4 || fatigue >= 5) {
    return {
      factor: 0,
      label: "Descanso recomendado",
      message:
        "Hoy se recomienda descanso o movilidad suave por dolor o fatiga alta."
    };
  }

  if (sleep <= 2 || stress >= 4 || fatigue >= 4 || mood <= 2) {
    return {
      factor: 0.5,
      label: "Sesión reducida",
      message: "Hoy se recomienda reducir volumen e intensidad."
    };
  }

  return {
    factor: 1,
    label: "Sesión normal",
    message: "Estado favorable para realizar la sesión planificada."
  };
>>>>>>> 576b4005b62eace3620becba8b991738cb1e630f
}

module.exports = {
  calculateLoadFactor
};