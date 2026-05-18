import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://train-track-mvp.onrender.com/api';

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
      print('[ERROR] Excepcion de red en registro: $e');
      return false;
    }
  }

  static Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        print('[+] Verificacion exitosa. Token guardado.');
        return true;
      } else {
        print('[ERROR] Fallo en verificacion: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ERROR] Excepcion de red en verificacion: $e');
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        print('[+] Login exitoso. Token guardado.');
        return true;
      } else {
        print('[ERROR] Login fallido: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ERROR] Excepcion de red: $e');
      return false;
    }
  }

  static Future<bool> adminLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('[ADMIN LOGIN] URL: $baseUrl/admin/login');
      print('[ADMIN LOGIN] Status: ${response.statusCode}');
      print('[ADMIN LOGIN] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token == null || token.toString().isEmpty) {
          print('[ERROR] Login admin sin token');
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_jwt_token', token);

        print('[+] Login admin exitoso. Token admin guardado.');
        return true;
      } else {
        print(
          '[ERROR] Login admin fallido: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('[ERROR] Excepcion de red en login admin: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_jwt_token');
  }

  static Future<void> adminLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_jwt_token');
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    print(
      '[ERROR] Error al obtener perfil: ${response.statusCode} - ${response.body}',
    );
    return null;
  }

  static Future<bool> updateProfile({
    String? username,
    String? avatar,
  }) async {
    final token = await getToken();

    if (token == null) {
      print('[ERROR] No autorizado para actualizar perfil');
      return false;
    }

    final body = <String, dynamic>{};

    if (username != null) {
      body['username'] = username;
    }

    if (avatar != null) {
      body['avatar'] = avatar;
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('[+] Perfil actualizado correctamente');
        return true;
      }

      print(
        '[ERROR] Error al actualizar perfil: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e) {
      print('[ERROR] Excepcion al actualizar perfil: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> generateWorkout(
    Map<String, dynamic> wellnessData,
  ) async {
    final token = await getToken();

    if (token == null) {
      print('[ERROR] No hay token. El usuario debe iniciar sesion primero.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(wellnessData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print(
          '[ERROR] Rechazo del servidor: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('[ERROR] Caida de red al generar sesion: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getWellnessHistory() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No autorizado');
    }

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
      throw Exception('Error al cargar historial: ${response.statusCode}');
    }
  }

  static Future<void> registerRpe({
    required String sessionId,
    required int rpe,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No autorizado');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/workouts/$sessionId/rpe'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rpe': rpe,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al registrar RPE');
    }
  }

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

  static Future<Map<String, dynamic>> getRecoveryStatus() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No autorizado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/recovery'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al obtener recuperacion muscular: ${response.statusCode}',
      );
    }
  }

  // =========================
  // ADMIN - USUARIOS
  // =========================

  static Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final token = await getAdminToken();

    if (token == null) {
      throw Exception('No hay token admin');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ADMIN USERS] Status: ${response.statusCode}');
      print('[ADMIN USERS] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] ?? [];

        return List<Map<String, dynamic>>.from(users);
      }

      throw Exception('Error al cargar usuarios admin');
    } catch (e) {
      print('[ADMIN USERS] Error: $e');
      rethrow;
    }
  }

  static Future<bool> deleteAdminUser(String userId) async {
    final token = await getAdminToken();

    if (token == null) {
      print('[ADMIN DELETE USER] No hay token admin');
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ADMIN DELETE USER] Status: ${response.statusCode}');
      print('[ADMIN DELETE USER] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('[ADMIN DELETE USER] Error: $e');
      return false;
    }
  }

  // =========================
  // ADMIN - EJERCICIOS
  // =========================

  static Future<List<Map<String, dynamic>>> getAdminExercises() async {
    final token = await getAdminToken();

    if (token == null) {
      throw Exception('No hay token admin');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/exercises'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ADMIN EXERCISES] Status: ${response.statusCode}');
      print('[ADMIN EXERCISES] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exercises = data['exercises'] ?? [];

        return List<Map<String, dynamic>>.from(exercises);
      }

      throw Exception('Error al cargar ejercicios admin');
    } catch (e) {
      print('[ADMIN EXERCISES] Error: $e');
      rethrow;
    }
  }

  static Future<bool> createAdminExercise({
    required String name,
    required String muscleGroup,
    required String description,
    required String instructions,
    required String level,
    String videoUrl = '',
    bool isActive = true,
  }) async {
    final token = await getAdminToken();

    if (token == null) {
      print('[ADMIN CREATE EXERCISE] No hay token admin');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/exercises'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'muscleGroup': muscleGroup,
          'description': description,
          'instructions': instructions,
          'level': level,
          'videoUrl': videoUrl,
          'isActive': isActive,
        }),
      );

      print('[ADMIN CREATE EXERCISE] Status: ${response.statusCode}');
      print('[ADMIN CREATE EXERCISE] Body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('[ADMIN CREATE EXERCISE] Error: $e');
      return false;
    }
  }

  static Future<bool> updateAdminExercise({
    required String exerciseId,
    required Map<String, dynamic> updates,
  }) async {
    final token = await getAdminToken();

    if (token == null) {
      print('[ADMIN UPDATE EXERCISE] No hay token admin');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/exercises/$exerciseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      print('[ADMIN UPDATE EXERCISE] Status: ${response.statusCode}');
      print('[ADMIN UPDATE EXERCISE] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('[ADMIN UPDATE EXERCISE] Error: $e');
      return false;
    }
  }

  static Future<bool> deleteAdminExercise(String exerciseId) async {
    final token = await getAdminToken();

    if (token == null) {
      print('[ADMIN DELETE EXERCISE] No hay token admin');
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/exercises/$exerciseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ADMIN DELETE EXERCISE] Status: ${response.statusCode}');
      print('[ADMIN DELETE EXERCISE] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('[ADMIN DELETE EXERCISE] Error: $e');
      return false;
    }
  }
}