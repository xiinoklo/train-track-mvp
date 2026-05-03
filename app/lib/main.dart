import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TrainTrackApp());
}

class TrainTrackApp extends StatelessWidget {
  const TrainTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainTrack MVP',
      debugShowCheckedModeBanner: false, // Quitamos la banda roja fea de "DEBUG"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Si tienes otra fuente configurada, puedes cambiarla
      ),
      // El punto de entrada oficial de tu MVP
      home: const LoginScreen(), 
    );
  }
}