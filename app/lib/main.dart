import 'package:flutter/material.dart';
import 'screens/wellness_form_screen.dart'; // Importas la pantalla que creaste

void main() {
  runApp(const TrainTrackApp());
}

class TrainTrackApp extends StatelessWidget {
  const TrainTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Track MVP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Aquí le dices que la pantalla inicial sea el formulario
      home: const WellnessFormScreen(), 
    );
  }
}