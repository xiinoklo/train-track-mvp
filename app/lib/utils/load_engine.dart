class LoadEngine {
  // 1. Calculamos el "Factor de Carga" basado en el bienestar
  static double calculateLoadFactor({
    required double sleep,
    required double pain,
    required double fatigue,
    required double stress,
    required double mood,
  }) {
    // Regla Crítica: Dolor alto o Fatiga extrema -> Descanso preventivo
    if (pain >= 4 || fatigue == 5) {
      return 0.0; // 0% de la carga normal (Descanso)
    }

    // Regla de Precaución: Mal sueño, Estrés alto o Fatiga moderada -> Deload
    if (sleep <= 2 || stress >= 4 || fatigue >= 4) {
      return 0.5; // 50% de la carga normal (Reduce volumen a la mitad)
    }

    // Estado Óptimo: Todo normal o bien -> Entrenamiento completo
    return 1.0; // 100% de la carga
  }

  // 2. Aplicamos el factor a la rutina base
  static List<Map<String, dynamic>> adjustRoutine(
      List<Map<String, dynamic>> baseRoutine, double loadFactor) {
    
    // Si el factor es 0, cancelamos la rutina de pesas
    if (loadFactor == 0.0) {
      return [
        {
          "nombre": "Descanso Activo / Recuperación",
          "grupo": "Movilidad",
          "series": "1",
          "repeticiones": "15 minutos",
          "indicaciones": "Tus indicadores sugieren sobrecarga. Realiza estiramientos ligeros y descansa.",
        }
      ];
    }

    // Si hay que entrenar, ajustamos las series matemáticamente
    return baseRoutine.map((ejercicio) {
      int originalSets = int.parse(ejercicio["series"]);
      // Multiplicamos las series por el factor (ej. 4 series * 0.5 = 2 series)
      int adjustedSets = (originalSets * loadFactor).round();
      
      // Aseguramos que mínimo se haga 1 serie
      if (adjustedSets < 1) adjustedSets = 1;

      return {
        "nombre": ejercicio["nombre"],
        "grupo": ejercicio["grupo"],
        "series": adjustedSets.toString(),
        "repeticiones": ejercicio["repeticiones"],
        // Cambiamos el mensaje si el entrenamiento fue reducido
        "indicaciones": loadFactor < 1.0 
            ? "Carga reducida por precaución. Prioriza la técnica y no llegues al fallo." 
            : ejercicio["indicaciones"],
      };
    }).toList();
  }
}