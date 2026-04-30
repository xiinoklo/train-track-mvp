import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'workout_screen.dart';

class WellnessFormScreen extends StatefulWidget {
  const WellnessFormScreen({Key? key}) : super(key: key);

  @override
  State<WellnessFormScreen> createState() => _WellnessFormScreenState();
}

class _WellnessFormScreenState extends State<WellnessFormScreen> {
  double sleep = 3;
  double pain = 1;
  double fatigue = 3;
  double stress = 3;
  double mood = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Registro de Bienestar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              'Eval¨²a tu estado actual (1 al 5)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            _buildMetricCard(
              'Calidad de Sue?o',
              sleep,
              (val) => setState(() => sleep = val),
              false,
            ),
            _buildMetricCard(
              'Nivel de Dolor',
              pain,
              (val) => setState(() => pain = val),
              true,
            ),
            _buildMetricCard(
              'Nivel de Fatiga',
              fatigue,
              (val) => setState(() => fatigue = val),
              true,
            ),
            _buildMetricCard(
              'Nivel de Estr¨¦s',
              stress,
              (val) => setState(() => stress = val),
              true,
            ),
            _buildMetricCard(
              'Estado de ¨¢nimo',
              mood,
              (val) => setState(() => mood = val),
              false,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Analizando bienestar... Generando rutina ajustada.',
                    ),
                  ),
                );

                try {
                  final data = await ApiService.generateWorkout(
                    sleep: sleep.round(),
                    pain: pain.round(),
                    fatigue: fatigue.round(),
                    stress: stress.round(),
                    mood: mood.round(),
                  );

                  final double factorCalculado =
    (data['loadFactor'] as num).toDouble();

final List<Map<String, dynamic>> exercises =
    (data['exercises'] as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

if (!mounted) return;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => WorkoutScreen(
      loadFactor: factorCalculado,
      recommendation: data['recommendation'],
      message: data['message'],
      exercises: exercises,
    ),
  ),
);
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error al conectar con el backend. Revisa que el servidor est¨¦ encendido.',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'GENERAR ENTRENAMIENTO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    double value,
    Function(double) onChanged,
    bool inverseColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value.round().toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
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

  Color _getDynamicColor(double value, bool inverse) {
    if (inverse) {
      if (value <= 2) return Colors.green;
      if (value == 3) return Colors.orange;
      return Colors.red;
    } else {
      if (value >= 4) return Colors.green;
      if (value == 3) return Colors.orange;
      return Colors.red;
    }
  }
}