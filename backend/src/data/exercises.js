const exercises = [
  {
    name: "Press de banca",
    level: "principiante",
    muscleGroup: "pecho",
    description: "Empuje horizontal para desarrollar pecho, hombro anterior y triceps.",
    instructions:
      "Apoya bien la espalda, baja la barra con control hacia el pecho y empuja sin bloquear agresivamente los codos.",
    videoUrl: "https://www.youtube.com/watch?v=rT7DgCr-3pg",
    isActive: true
  },
  {
    name: "Flexiones de pecho",
    level: "principiante",
    muscleGroup: "pecho",
    description: "Ejercicio de empuje con peso corporal para pecho y triceps.",
    instructions:
      "Mantén el cuerpo alineado, baja el pecho hacia el suelo y empuja con control.",
    videoUrl: "https://www.youtube.com/watch?v=IODxDxX7oi4",
    isActive: true
  },
  {
    name: "Press inclinado con mancuernas",
    level: "intermedio",
    muscleGroup: "pecho",
    description: "Empuje inclinado con énfasis en la parte superior del pecho.",
    instructions:
      "Mantén las escápulas estables, baja las mancuernas hasta una posición cómoda y empuja sin perder control.",
    videoUrl: "https://www.youtube.com/watch?v=8iPEnn-ltC8",
    isActive: true
  },
  {
    name: "Remo en polea baja",
    level: "principiante",
    muscleGroup: "espalda",
    description: "Tracción horizontal para espalda media.",
    instructions:
      "Lleva los codos hacia atrás, junta ligeramente las escápulas y evita inclinar demasiado el torso.",
    videoUrl: "https://www.youtube.com/watch?v=GZbfZ033f74",
    isActive: true
  },
  {
    name: "Jalón al pecho",
    level: "principiante",
    muscleGroup: "espalda",
    description: "Tracción vertical para dorsales.",
    instructions:
      "Tira la barra hacia la parte alta del pecho, mantén el torso estable y controla la subida.",
    videoUrl: "https://www.youtube.com/watch?v=CAwf7n6Luuc",
    isActive: true
  },
  {
    name: "Remo con mancuerna",
    level: "intermedio",
    muscleGroup: "espalda",
    description: "Remo unilateral para dorsales y espalda media.",
    instructions:
      "Apoya una mano, mantén la espalda neutra y lleva el codo hacia la cadera.",
    videoUrl: "https://www.youtube.com/watch?v=pYcpY20QaE8",
    isActive: true
  },
  {
    name: "Sentadilla goblet",
    level: "principiante",
    muscleGroup: "piernas",
    description: "Sentadilla básica para tren inferior.",
    instructions:
      "Mantén el pecho arriba, baja controlado y empuja desde el medio del pie.",
    videoUrl: "https://www.youtube.com/watch?v=MeIiIdhvXT4",
    isActive: true
  },
  {
    name: "Prensa de piernas",
    level: "principiante",
    muscleGroup: "piernas",
    description: "Ejercicio guiado para fuerza general de piernas.",
    instructions:
      "Coloca los pies firmes, baja sin despegar la cadera y empuja sin bloquear las rodillas.",
    videoUrl: "https://www.youtube.com/watch?v=IZxyjW7MPJQ",
    isActive: true
  },
  {
    name: "Zancadas caminando",
    level: "intermedio",
    muscleGroup: "piernas",
    description: "Trabajo unilateral para piernas, gluteos y estabilidad.",
    instructions:
      "Da un paso largo, baja controlado y empuja con la pierna adelantada para avanzar.",
    videoUrl: "https://www.youtube.com/watch?v=L8fvypPrzzs",
    isActive: true
  },
  {
    name: "Press militar con mancuernas",
    level: "principiante",
    muscleGroup: "hombros",
    description: "Empuje vertical para hombros.",
    instructions:
      "Empuja las mancuernas sobre la cabeza, mantén el abdomen firme y baja con control.",
    videoUrl: "https://www.youtube.com/watch?v=B-aVuyhvLHU",
    isActive: true
  },
  {
    name: "Elevaciones laterales",
    level: "principiante",
    muscleGroup: "hombros",
    description: "Aislamiento para deltoides lateral.",
    instructions:
      "Eleva los brazos hasta la línea de los hombros con codos suaves y sin balancear el torso.",
    videoUrl: "https://www.youtube.com/watch?v=3VcKaXpzqRo",
    isActive: true
  },
  {
    name: "Face pull",
    level: "intermedio",
    muscleGroup: "hombros",
    description: "Trabajo de deltoide posterior y estabilidad escapular.",
    instructions:
      "Tira la cuerda hacia la cara, separa las manos al final y controla el regreso.",
    videoUrl: "https://www.youtube.com/watch?v=eIq5CB9JfKE",
    isActive: true
  },
  {
    name: "Curl de biceps con mancuernas",
    level: "principiante",
    muscleGroup: "biceps",
    description: "Aislamiento básico para biceps.",
    instructions:
      "Mantén los codos cerca del cuerpo, sube sin balancearte y baja lento.",
    videoUrl: "https://www.youtube.com/watch?v=sAq_ocpRh_I",
    isActive: true
  },
  {
    name: "Curl martillo",
    level: "principiante",
    muscleGroup: "biceps",
    description: "Curl con agarre neutro para biceps y braquial.",
    instructions:
      "Sube las mancuernas con las palmas enfrentadas y controla la bajada.",
    videoUrl: "https://www.youtube.com/watch?v=zC3nLlEvin4",
    isActive: true
  },
  {
    name: "Fondos asistidos",
    level: "intermedio",
    muscleGroup: "triceps",
    description: "Empuje para triceps, pecho y hombro anterior.",
    instructions:
      "Baja con control, mantén hombros estables y empuja hasta extender los codos.",
    videoUrl: "https://www.youtube.com/watch?v=2z8JmcrW-As",
    isActive: true
  },
  {
    name: "Extensión de triceps en polea",
    level: "principiante",
    muscleGroup: "triceps",
    description: "Aislamiento guiado para triceps.",
    instructions:
      "Fija los codos al costado, extiende hacia abajo y evita mover los hombros.",
    videoUrl: "https://www.youtube.com/watch?v=2-LAMcpzODU",
    isActive: true
  },
  {
    name: "Curl y extensión de brazos",
    level: "principiante",
    muscleGroup: "brazos",
    description: "Circuito simple para trabajo general de brazos.",
    instructions:
      "Alterna curl de biceps y extensión de triceps con poco peso y técnica limpia.",
    videoUrl: "https://www.youtube.com/watch?v=ykJmrZ5v0Oo",
    isActive: true
  },
  {
    name: "Plancha frontal",
    level: "principiante",
    muscleGroup: "core",
    description: "Ejercicio isométrico para estabilidad del tronco.",
    instructions:
      "Mantén abdomen firme, cadera alineada y respira sin perder la postura.",
    videoUrl: "https://www.youtube.com/watch?v=pSHjTRCQxIw",
    isActive: true
  },
  {
    name: "Dead bug",
    level: "principiante",
    muscleGroup: "core",
    description: "Control lumbo-pélvico para core.",
    instructions:
      "Mantén la espalda baja estable mientras extiendes brazo y pierna contraria.",
    videoUrl: "https://www.youtube.com/watch?v=g_BYB0R-4Ws",
    isActive: true
  },
  {
    name: "Pallof press",
    level: "intermedio",
    muscleGroup: "core",
    description: "Anti-rotación para estabilidad central.",
    instructions:
      "Empuja la polea al frente, resiste la rotación y vuelve lento al pecho.",
    videoUrl: "https://www.youtube.com/watch?v=AH_QZLm_0-s",
    isActive: true
  },
  {
    name: "Hip thrust",
    level: "principiante",
    muscleGroup: "gluteos",
    description: "Extensión de cadera con énfasis en gluteos.",
    instructions:
      "Apoya la espalda alta, sube la cadera apretando gluteos y evita arquear la zona lumbar.",
    videoUrl: "https://www.youtube.com/watch?v=SEdqd1n0cvg",
    isActive: true
  },
  {
    name: "Puente de gluteos",
    level: "principiante",
    muscleGroup: "gluteos",
    description: "Activación básica de gluteos con peso corporal.",
    instructions:
      "Empuja con los talones, sube la cadera y mantén una pausa breve arriba.",
    videoUrl: "https://www.youtube.com/watch?v=wPM8icPu6H8",
    isActive: true
  },
  {
    name: "Extensión de cuadriceps",
    level: "principiante",
    muscleGroup: "cuadriceps",
    description: "Aislamiento guiado para cuadriceps.",
    instructions:
      "Extiende las rodillas con control, pausa arriba y baja sin soltar el peso.",
    videoUrl: "https://www.youtube.com/watch?v=YyvSfVjQeL0",
    isActive: true
  },
  {
    name: "Sentadilla frontal",
    level: "intermedio",
    muscleGroup: "cuadriceps",
    description: "Variante de sentadilla con énfasis en cuadriceps.",
    instructions:
      "Mantén el torso erguido, codos altos y baja hasta una profundidad cómoda.",
    videoUrl: "https://www.youtube.com/watch?v=uYumuL_G_V0",
    isActive: true
  },
  {
    name: "Curl femoral acostado",
    level: "principiante",
    muscleGroup: "isquios",
    description: "Aislamiento para isquiotibiales.",
    instructions:
      "Flexiona las rodillas con control, evita levantar la cadera y baja lento.",
    videoUrl: "https://www.youtube.com/watch?v=1Tq3QdYUuHs",
    isActive: true
  },
  {
    name: "Peso muerto rumano",
    level: "intermedio",
    muscleGroup: "femorales",
    description: "Bisagra de cadera para femorales, gluteos y espalda baja.",
    instructions:
      "Lleva la cadera hacia atrás, mantén espalda neutra y siente tensión en la parte posterior de las piernas.",
    videoUrl: "https://www.youtube.com/watch?v=JCXUYuzwNrM",
    isActive: true
  },
  {
    name: "Elevación de pantorrillas de pie",
    level: "principiante",
    muscleGroup: "pantorrillas",
    description: "Aislamiento básico para gemelos.",
    instructions:
      "Sube lo más alto posible, pausa arriba y baja controlado hasta estirar.",
    videoUrl: "https://www.youtube.com/watch?v=-M4-G8p8fmc",
    isActive: true
  },
  {
    name: "Elevación de pantorrillas sentado",
    level: "principiante",
    muscleGroup: "pantorrillas",
    description: "Trabajo de sóleo y pantorrilla en posición sentada.",
    instructions:
      "Empuja con la punta de los pies, pausa arriba y controla el descenso.",
    videoUrl: "https://www.youtube.com/watch?v=JbyjNymZOt0",
    isActive: true
  }
];

module.exports = exercises;
