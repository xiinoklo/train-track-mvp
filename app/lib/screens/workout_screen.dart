import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class WorkoutScreen extends StatefulWidget {
  final double loadFactor;
  final String recommendation;
  final String message;
  final List<Map<String, dynamic>> exercises;

  const WorkoutScreen({
    Key? key,
    required this.loadFactor,
    required this.recommendation,
    required this.message,
    required this.exercises,
  }) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Future<void> _launchYoutubeVideo(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el video: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRestDay = widget.exercises.isEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Rutina del Día',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildRecommendationCard(),
          Expanded(
            child: isRestDay
                ? _buildRestMessage()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: widget.exercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(widget.exercises[index]);
                    },
                  ),
          ),
          if (!isRestDay) _buildFinishButton(context),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.recommendation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRestMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 60,
                  color: Colors.indigo,
                ),
                SizedBox(height: 16),
                Text(
                  'Descanso activo / recuperación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Hoy no se recomienda una rutina de fuerza. Prioriza movilidad suave, caminata ligera o recuperación.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final String name = exercise['name'] ?? 'Ejercicio';
    final String muscleGroup = exercise['muscleGroup'] ?? 'General';
    final int sets = exercise['sets'] ?? 0;
    final String reps = exercise['reps'] ?? '-';
    final String instructions = exercise['instructions'] ?? '';
    final String? videoUrl = exercise['videoUrl'];

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
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    muscleGroup,
                    style: TextStyle(
                      color: Colors.indigo[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              '$sets Series x $reps Reps',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              instructions,
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            if (videoUrl != null && videoUrl.isNotEmpty)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Ver Video de Ejecución'),
                onPressed: () => _launchYoutubeVideo(videoUrl),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _mostrarDialogoRPE(context),
        child: const Text(
          'FINALIZAR ENTRENAMIENTO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _mostrarDialogoRPE(BuildContext context) {
    double rpe = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Registrar RPE'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¿Qué tan exigente fue el entrenamiento?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    rpe.round().toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Slider(
                    value: rpe,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: Colors.indigo,
                    label: rpe.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        rpe = value;
                      });
                    },
                  ),
                  const Text(
                    '1 = muy fácil · 10 = máximo esfuerzo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiService.registerRpe(
                        rpe: rpe.round(),
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'RPE registrado en backend: ${rpe.round()}',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error al guardar RPE en el backend.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}