import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ATENCIÓN: Si pruebas en dispositivo físico o web, usa la IP de tu PC o localhost.
  // 10.0.2.2 es el mapeo estándar para emuladores Android hacia localhost.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Función para Registrar Usuario + Onboarding
  static Future<bool> registerUser({
    required String email,
    required String password,
    required int age,
    required String gender,
    required String experienceLevel,
    required String mainGoal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'age': age,
          'gender': gender,
          'experienceLevel': experienceLevel,
          'mainGoal': mainGoal,
        }),
      );

      if (response.statusCode == 201) {
        print('[+] Registro exitoso en DB');
        return true;
      } else {
        print('[ERROR] Registro fallido: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ERROR] Excepción de red en registro: $e');
      return false;
    }
  }

  // Función para Verificar el Código OTP
  static Future<bool> verifyCode({required String email, required String code}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Guardar el token para que el usuario quede logueado inmediatamente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        print('[+] Verificación exitosa. Token guardado.');
        return true;
      } else {
        print('[ERROR] Fallo en verificación: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ERROR] Excepción de red en verificación: $e');
      return false;
    }
  }

  // Función para Login
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Guardar el token en el almacenamiento del celular
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        print('[+] Login exitoso. Token guardado.');
        return true;
      } else {
        print('[ERROR] Login fallido: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ERROR] Excepción de red: $e');
      return false;
    }
  }

  // Función para leer el token (lo usarás después para el Bienestar)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Función para enviar el bienestar y recibir la sesión generada
  static Future<Map<String, dynamic>?> generateWorkout(Map<String, int> wellnessData) async {
    // 1. Recuperamos el token que guardaste en el login
    final token = await getToken();
    
    if (token == null) {
      print('[ERROR] No hay token. El usuario debe iniciar sesión primero.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts/generate'),
        headers: {
          'Content-Type': 'application/json',
          // 2. Inyectamos el escudo de seguridad
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode(wellnessData),
      );

      if (response.statusCode == 201) {
        // La API nos devuelve la sesión y la recomendación
        return jsonDecode(response.body); 
      } else {
        print('[ERROR] Rechazo del servidor: \${response.statusCode} - \${response.body}');
        return null;
      }
    } catch (e) {
      print('[ERROR] Caída de red al generar sesión: \$e');
      return null;
    }
  }

  // Obtener el historial de bienestar (Para HistoryScreen)
  static Future<Map<String, dynamic>> getWellnessHistory() async {
    final token = await getToken();
    if (token == null) throw Exception("No autorizado");

    final response = await http.get(
      Uri.parse('$baseUrl/wellness'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al cargar historial: ${response.statusCode}");
    }
  }

  // Registrar el RPE (Para WorkoutScreen)
  // Nota: Ahora exige el sessionId real
  static Future<void> registerRpe({required String sessionId, required int rpe}) async {
    final token = await getToken();
    if (token == null) throw Exception("No autorizado");

    final response = await http.post(
      Uri.parse('$baseUrl/workouts/$sessionId/rpe'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rpe': rpe}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al registrar RPE");
    }
  }

  // Función para guardar el registro de bienestar en el historial
  static Future<bool> saveWellness(Map<String, int> wellnessData) async {
    final token = await getToken();
    if (token == null) {
      print('[ERROR] No autorizado para guardar bienestar');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wellness'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(wellnessData),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('[ERROR] Error al guardar bienestar: $e');
      return false;
    }
  }
}