import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'workout_screen.dart';

class SavedRoutinesScreen extends StatefulWidget {
  const SavedRoutinesScreen({super.key});

  @override
  State<SavedRoutinesScreen> createState() => _SavedRoutinesScreenState();
}

class _SavedRoutinesScreenState extends State<SavedRoutinesScreen> {
  late Future<List<Map<String, dynamic>>> _routinesFuture;

  static const primaryColor = Color(0xFF1E3A8A);
  static const warningColor = Color(0xFFF59E0B);
  static const dangerColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _routinesFuture = ApiService.getSavedRoutines();
  }

  void _refresh() {
    setState(() {
      _routinesFuture = ApiService.getSavedRoutines();
    });
  }

  Future<void> _startRoutine(Map<String, dynamic> routine) async {
    final data = await ApiService.startSavedRoutine(routine['_id'].toString());
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          sessionId: data['sessionId']?.toString() ?? '',
          loadFactor: (data['loadFactor'] as num?)?.toDouble() ?? 1,
          recommendation:
              data['recommendation']?.toString() ?? 'Rutina personalizada',
          message: data['message']?.toString() ?? '',
          exercises: List<Map<String, dynamic>>.from(data['exercises'] ?? []),
          canCustomizeWorkout: true,
          canSaveCustomRoutine: true,
        ),
      ),
    );
  }

  Future<void> _deleteRoutine(String id) async {
    final success = await ApiService.deleteSavedRoutine(id);
    if (!mounted) return;
    if (success) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis rutinas'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _routinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            );
          }

          final routines = snapshot.data ?? [];
          if (routines.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Aún no tienes rutinas guardadas. Ajusta una rutina de entrenamiento y usa "Guardar como mi rutina".',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                final exercises = List.from(routine['exercises'] ?? []);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFF7ED),
                          child: Icon(
                            Icons.bookmark_rounded,
                            color: warningColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine['name']?.toString() ?? 'Mi rutina',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${exercises.length} ejercicios'),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _deleteRoutine(routine['_id'].toString()),
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: dangerColor,
                        ),
                        FilledButton(
                          onPressed: () => _startRoutine(routine),
                          style: FilledButton.styleFrom(
                            backgroundColor: warningColor,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('Iniciar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
