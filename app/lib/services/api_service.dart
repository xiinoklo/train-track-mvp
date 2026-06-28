import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WellnessSaveResult {
  const WellnessSaveResult({required this.saved, required this.queuedOffline});

  final bool saved;
  final bool queuedOffline;
}

class ApiService {
  // static const String baseUrl = 'https://train-track-mvp.onrender.com/api';
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://train-track-mvp.onrender.com/api',
  );

  static void _log(Object message) {
    developer.log(message.toString(), name: 'ApiService');
  }

  static const String _pendingWellnessKey = 'pending_wellness_sync';

  static Future<void> _queueWellnessForSync(
    Map<String, int> wellnessData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingWellnessKey) ?? [];

    pending.add(
      jsonEncode({
        ...wellnessData,
        'queuedAt': DateTime.now().toIso8601String(),
      }),
    );

    await prefs.setStringList(_pendingWellnessKey, pending);
    _log('[OFFLINE] Bienestar guardado en cola local (${pending.length})');
  }

  static Future<int> getPendingWellnessCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pendingWellnessKey)?.length ?? 0;
  }

  static Future<int> syncPendingWellness() async {
    final token = await getToken();

    if (token == null) {
      return 0;
    }

    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingWellnessKey) ?? [];

    if (pending.isEmpty) {
      return 0;
    }

    final remaining = <String>[];
    var synced = 0;

    for (final raw in pending) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(raw));
        final wellnessData = <String, int>{
          'sleep': (decoded['sleep'] as num).toInt(),
          'pain': (decoded['pain'] as num).toInt(),
          'fatigue': (decoded['fatigue'] as num).toInt(),
          'stress': (decoded['stress'] as num).toInt(),
          'mood': (decoded['mood'] as num).toInt(),
        };

        final response = await http.post(
          Uri.parse('$baseUrl/wellness'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(wellnessData),
        );

        if (response.statusCode == 201) {
          synced++;
        } else {
          remaining.add(raw);
        }
      } catch (e) {
        remaining.add(raw);
      }
    }

    await prefs.setStringList(_pendingWellnessKey, remaining);

    if (synced > 0) {
      _log('[OFFLINE] Registros de bienestar sincronizados: $synced');
    }

    return synced;
  }

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
        _log('[+] Registro exitoso en DB');
        return true;
      } else {
        _log('[ERROR] Registro fallido: ${response.body}');
        return false;
      }
    } catch (e) {
      _log('[ERROR] Excepcion de red en registro: $e');
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
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'] ?? 'user';
        final isAdmin = data['isAdmin'] == true || role == 'admin';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_role', role);
        await prefs.setBool('is_admin', isAdmin);
        await syncPendingWellness();

        _log('[+] Verificacion exitosa. Token guardado.');
        return true;
      } else {
        _log('[ERROR] Fallo en verificacion: ${response.body}');
        return false;
      }
    } catch (e) {
      _log('[ERROR] Excepcion de red en verificacion: $e');
      return false;
    }
  }

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
        final role = data['role'] ?? 'user';
        final isAdmin = data['isAdmin'] == true || role == 'admin';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_role', role);
        await prefs.setBool('is_admin', isAdmin);
        await syncPendingWellness();

        _log('[+] Login exitoso. Token guardado.');
        _log('[+] Rol: $role | Admin: $isAdmin');

        return true;
      } else {
        _log(
          '[ERROR] Login fallido: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      _log('[ERROR] Excepcion de red: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  static Future<String?> getAdminToken() async {
    return getToken();
  }

  static Future<void> adminLogout() async {
    return;
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

    _log(
      '[ERROR] Error al obtener perfil: ${response.statusCode} - ${response.body}',
    );
    return null;
  }

  static Future<bool> updateProfile({String? username, String? avatar}) async {
    final token = await getToken();

    if (token == null) {
      _log('[ERROR] No autorizado para actualizar perfil');
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
        _log('[+] Perfil actualizado correctamente');
        return true;
      }

      _log(
        '[ERROR] Error al actualizar perfil: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e) {
      _log('[ERROR] Excepcion al actualizar perfil: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> generateWorkout(
    Map<String, dynamic> wellnessData,
  ) async {
    final token = await getToken();

    if (token == null) {
      _log('[ERROR] No hay token. El usuario debe iniciar sesion primero.');
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
        _log(
          '[ERROR] Rechazo del servidor: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      _log('[ERROR] Caida de red al generar sesion: $e');
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

  static Future<Map<String, dynamic>> registerRpe({
    required String sessionId,
    required int rpe,
    List<Map<String, dynamic>>? exercises,
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
      body: jsonEncode({'rpe': rpe, 'exercises': ?exercises}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al registrar RPE');
  }

  static Future<WellnessSaveResult> saveWellnessWithStatus(
    Map<String, int> wellnessData,
  ) async {
    final token = await getToken();

    if (token == null) {
      _log('[ERROR] No autorizado para guardar bienestar');
      return const WellnessSaveResult(saved: false, queuedOffline: false);
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

      if (response.statusCode == 201) {
        return const WellnessSaveResult(saved: true, queuedOffline: false);
      }

      _log(
        '[ERROR] Error al guardar bienestar: ${response.statusCode} - ${response.body}',
      );
      return const WellnessSaveResult(saved: false, queuedOffline: false);
    } catch (e) {
      _log('[ERROR] Error al guardar bienestar: $e');
      await _queueWellnessForSync(wellnessData);
      return const WellnessSaveResult(saved: true, queuedOffline: true);
    }
  }

  static Future<bool> saveWellness(Map<String, int> wellnessData) async {
    final result = await saveWellnessWithStatus(wellnessData);
    return result.saved;
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

      _log('[ADMIN USERS] Status: ${response.statusCode}');
      _log('[ADMIN USERS] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] ?? [];

        return List<Map<String, dynamic>>.from(users);
      }

      throw Exception('Error al cargar usuarios admin');
    } catch (e) {
      _log('[ADMIN USERS] Error: $e');
      rethrow;
    }
  }

  static Future<bool> deleteAdminUser(String userId) async {
    final token = await getAdminToken();

    if (token == null) {
      _log('[ADMIN DELETE USER] No hay token admin');
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

      _log('[ADMIN DELETE USER] Status: ${response.statusCode}');
      _log('[ADMIN DELETE USER] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      _log('[ADMIN DELETE USER] Error: $e');
      return false;
    }
  }

  // =========================
  // ADMIN - ESTADÍSTICAS
  // =========================

  static Future<Map<String, dynamic>> getAdminStats() async {
    final token = await getAdminToken();

    if (token == null) {
      throw Exception('No hay token admin');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _log('[ADMIN STATS] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception('Error al cargar estadisticas admin');
    } catch (e) {
      _log('[ADMIN STATS] Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAdminUserStats(String userId) async {
    final token = await getAdminToken();

    if (token == null) {
      throw Exception('No hay token admin');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _log('[ADMIN USER STATS] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception('Error al cargar estadisticas del usuario');
    } catch (e) {
      _log('[ADMIN USER STATS] Error: $e');
      rethrow;
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

      _log('[ADMIN EXERCISES] Status: ${response.statusCode}');
      _log('[ADMIN EXERCISES] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exercises = data['exercises'] ?? [];

        return List<Map<String, dynamic>>.from(exercises);
      }

      throw Exception('Error al cargar ejercicios admin');
    } catch (e) {
      _log('[ADMIN EXERCISES] Error: $e');
      rethrow;
    }
  }

  static Future<bool> createAdminExercise({
    required String name,
    required String muscleGroup,
    required String description,
    required String instructions,
    required String level,
    required int xp,
    String videoUrl = '',
    bool isActive = true,
  }) async {
    final token = await getAdminToken();

    if (token == null) {
      _log('[ADMIN CREATE EXERCISE] No hay token admin');
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
          'xp': xp,
          'videoUrl': videoUrl,
          'isActive': isActive,
        }),
      );

      _log('[ADMIN CREATE EXERCISE] Status: ${response.statusCode}');
      _log('[ADMIN CREATE EXERCISE] Body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      _log('[ADMIN CREATE EXERCISE] Error: $e');
      return false;
    }
  }

  static Future<bool> updateAdminExercise({
    required String exerciseId,
    required Map<String, dynamic> updates,
  }) async {
    final token = await getAdminToken();

    if (token == null) {
      _log('[ADMIN UPDATE EXERCISE] No hay token admin');
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

      _log('[ADMIN UPDATE EXERCISE] Status: ${response.statusCode}');
      _log('[ADMIN UPDATE EXERCISE] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      _log('[ADMIN UPDATE EXERCISE] Error: $e');
      return false;
    }
  }

  static Future<bool> deleteAdminExercise(String exerciseId) async {
    final token = await getAdminToken();

    if (token == null) {
      _log('[ADMIN DELETE EXERCISE] No hay token admin');
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

      _log('[ADMIN DELETE EXERCISE] Status: ${response.statusCode}');
      _log('[ADMIN DELETE EXERCISE] Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      _log('[ADMIN DELETE EXERCISE] Error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['exercises'] ?? []);
    }

    throw Exception('Error al cargar ejercicios');
  }

  static Future<Map<String, dynamic>> getAdminUserRoutines(
    String userId,
  ) async {
    final token = await getAdminToken();
    if (token == null) throw Exception('No hay token admin');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$userId/routines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al cargar rutinas');
  }

  static Future<bool> deleteAdminRoutine({
    required String routineId,
    required String type,
  }) async {
    final token = await getAdminToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/routines/$type/$routineId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> getSavedRoutines() async {
    final token = await getToken();
    if (token == null) throw Exception('No autorizado');

    final response = await http.get(
      Uri.parse('$baseUrl/routines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cargar rutinas');
    }
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['routines'] ?? []);
  }

  static Future<bool> saveRoutine({
    required String name,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/routines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'exercises': exercises}),
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>> startSavedRoutine(
    String routineId,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('No autorizado');

    final response = await http.post(
      Uri.parse('$baseUrl/routines/$routineId/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error al iniciar rutina');
  }

  static Future<bool> deleteSavedRoutine(String routineId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/routines/$routineId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
