import 'package:flutter/material.dart';
import '../utils/load_engine.dart'; // Importamos la lógica del motor de carga
import 'workout_screen.dart';     // Para la navegación a la rutina

class WellnessFormScreen extends StatefulWidget {
  const WellnessFormScreen({Key? key}) : super(key: key);

  @override
  _WellnessFormScreenState createState() => _WellnessFormScreenState();
}

class _WellnessFormScreenState extends State<WellnessFormScreen> {
  // Estado inicial de las 5 variables de bienestar requeridas por el MVP
  double sleep = 3;
  double pain = 1;
  double fatigue = 3;
  double stress = 3;
  double mood = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo sutil para resaltar las tarjetas[cite: 1]
      appBar: AppBar(
        title: const Text('Registro de Bienestar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Evalúa tu estado actual (1 al 5)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Generación de tarjetas para cada indicador solicitado[cite: 1]
            _buildMetricCard('😴 Calidad de Sueño', sleep, (val) => setState(() => sleep = val), false),
            _buildMetricCard('🤕 Nivel de Dolor', pain, (val) => setState(() => pain = val), true),
            _buildMetricCard('🔋 Nivel de Fatiga', fatigue, (val) => setState(() => fatigue = val), true),
            _buildMetricCard('🤯 Nivel de Estrés', stress, (val) => setState(() => stress = val), true),
            _buildMetricCard('😊 Estado de Ánimo', mood, (val) => setState(() => mood = val), false),

            const SizedBox(height: 30),
            
            // Botón de acción principal para generar la sesión ajustada[cite: 1]
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // 1. El motor calcula el factor de ajuste basado en los datos actuales[cite: 1]
                double factorCalculado = LoadEngine.calculateLoadFactor(
                  sleep: sleep,
                  pain: pain,
                  fatigue: fatigue,
                  stress: stress,
                  mood: mood,
                );

                // 2. Navegación a la rutina enviando el factor de carga[cite: 1]
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutScreen(loadFactor: factorCalculado),
                  ),
                );

                // Feedback visual rápido[cite: 1]
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analizando bienestar... Generando rutina ajustada.')),
                );
              },
              child: const Text(
                'GENERAR ENTRENAMIENTO', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget modular para las tarjetas de métricas (RNF-01: Usabilidad)[cite: 1]
  Widget _buildMetricCard(String title, double value, Function(double) onChanged, bool inverseColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  value.round().toString(), 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)
                ),
              ],
            ),
            Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: _getDynamicColor(value, inverseColor),
              inactiveColor: Colors.grey[300],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // Lógica de color dinámica para mejorar la comprensión visual (UX)[cite: 1]
  Color _getDynamicColor(double value, bool inverse) {
    if (inverse) {
      // Para Dolor/Fatiga/Estrés: 1 es verde (bueno), 5 es rojo (malo)[cite: 1]
      if (value <= 2) return Colors.green;
      if (value == 3) return Colors.orange;
      return Colors.red;
    } else {
      // Para Sueño/Ánimo: 1 es rojo (malo), 5 es verde (bueno)[cite: 1]
      if (value >= 4) return Colors.green;
      if (value == 3) return Colors.orange;
      return Colors.red;
    }
  }
}