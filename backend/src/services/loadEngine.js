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
}

module.exports = {
  calculateLoadFactor
};