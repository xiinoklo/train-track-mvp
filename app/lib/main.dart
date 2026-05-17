import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const TrainTrackApp());
}

class TrainTrackApp extends StatelessWidget {
  const TrainTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainTrack MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      // En lugar de ir ciego al Login, evaluamos si hay token
      home: const AuthWrapper(), 
    );
  }
}

// Pantalla de carga inteligente que decide a dónde ir
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ApiService.getToken(), // Leemos el SharedPreferences
      builder: (context, snapshot) {
        // Mientras lee la memoria, mostramos una pantalla de carga sutil
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E3A8A),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // Si tiene token, directo al panel. Si no, a loguearse.
        final token = snapshot.data;
        if (token != null && token.isNotEmpty) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}