import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Para Android Emulator usa: http://10.0.2.2:3000
  // Para navegador Chrome o app Windows usa: http://localhost:3000
  static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> generateWorkout({
    required int sleep,
    required int pain,
    required int fatigue,
    required int stress,
    required int mood,
  }) async {
    final url = Uri.parse('$baseUrl/api/workouts/generate');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sleep': sleep,
        'pain': pain,
        'fatigue': fatigue,
        'stress': stress,
        'mood': mood,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al generar entrenamiento');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getExercises() async {
    final url = Uri.parse('$baseUrl/api/exercises');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener ejercicios');
    }

    return jsonDecode(response.body);
  }
  static Future<Map<String, dynamic>> registerRpe({
  required int rpe,
}) async {
  final url = Uri.parse('$baseUrl/api/workouts/rpe');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'rpe': rpe,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al registrar RPE');
  }

  return jsonDecode(response.body);
}
}