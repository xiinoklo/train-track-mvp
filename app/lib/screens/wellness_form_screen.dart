import 'package:flutter/material.dart';

class WellnessFormScreen extends StatefulWidget {
  const WellnessFormScreen({Key? key}) : super(key: key);

  @override
  _WellnessFormScreenState createState() => _WellnessFormScreenState();
}

class _WellnessFormScreenState extends State<WellnessFormScreen> {
  // Valor inicial (3 = neutral)
  double nivelFatiga = 3; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienestar Diario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué tan fatigado te sientes hoy?', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Slider(
              value: nivelFatiga,
              min: 1,
              max: 5,
              divisions: 4, 
              label: nivelFatiga.round().toString(),
              activeColor: _getColorForValue(nivelFatiga),
              onChanged: (double value) {
                // Esto actualiza la pantalla cuando el usuario mueve el dedo
                setState(() {
                  nivelFatiga = value;
                });
              },
            ),
            Center(
              child: Text(
                'Nivel seleccionado: ${nivelFatiga.round()} / 5',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica simple para cambiar el color según la escala (UX)
  Color _getColorForValue(double value) {
    if (value <= 2) return Colors.green; // 1-2: Poca fatiga (Bien)
    if (value == 3) return Colors.orange; // 3: Normal
    return Colors.red; // 4-5: Mucha fatiga (Alerta)
  }
}