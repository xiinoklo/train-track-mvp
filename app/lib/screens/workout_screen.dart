import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importamos la librería
import '../utils/load_engine.dart';

class WorkoutScreen extends StatefulWidget {
  final double loadFactor;
  const WorkoutScreen({Key? key, required this.loadFactor}) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Agregamos el campo "url" a cada ejercicio
  final List<Map<String, dynamic>> rutinaBase = [
    {
      "nombre": "Press de Banca Plano",
      "grupo": "Pecho",
      "series": "4",
      "repeticiones": "10 - 12",
      "indicaciones": "Controla la fase excéntrica (bajada) en 3 segundos.",
      "url": "https://www.youtube.com/watch?v=tuwHzzO_cZk"
    },
    {
      "nombre": "Remo en Polea Baja",
      "grupo": "Espalda",
      "series": "4",
      "repeticiones": "12",
      "indicaciones": "Mantén la espalda recta y aprieta las escápulas.",
      "url": "https://www.youtube.com/watch?v=GZbfZ033f74"
    },
    {
      "nombre": "Curl de Bíceps Alternado",
      "grupo": "Brazos",
      "series": "3",
      "repeticiones": "15 por brazo",
      "indicaciones": "Evita el balanceo del torso.",
      "url": "https://www.youtube.com/watch?v=yTWO2th-RIY"
    }
  ];

  late List<Map<String, dynamic>> rutinaAjustada;

  @override
  void initState() {
    super.initState();
    rutinaAjustada = LoadEngine.adjustRoutine(rutinaBase, widget.loadFactor);
  }

  // Función para abrir los videos
  Future<void> _launchYoutubeVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el video: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Rutina del Día', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: rutinaAjustada.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(rutinaAjustada[index]);
              },
            ),
          ),
          _buildFinishButton(context),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> ejercicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Mismo diseño de cabecera que ya tenías)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(ejercicio["nombre"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(20)),
                  child: Text(ejercicio["grupo"], style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Divider(height: 24),
            Text('${ejercicio["series"]} Series  x  ${ejercicio["repeticiones"]} Reps', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text(ejercicio["indicaciones"], style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            
            // BOTÓN DE VIDEO YA FUNCIONAL
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700], 
                side: BorderSide(color: Colors.red[700]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Ver Video de Ejecución'),
              onPressed: () => _launchYoutubeVideo(ejercicio["url"]), // Llamada a la función
            ),
          ],
        ),
      ),
    );
  }

  // ... (Aquí iría el resto de tu código del botón de finalizar y el diálogo RPE)
  Widget _buildFinishButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _mostrarDialogoRPE(context),
        child: const Text('FINALIZAR ENTRENAMIENTO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _mostrarDialogoRPE(BuildContext context) {
    // ... (Tu código de RPE que ya funciona perfecto)
  }
}