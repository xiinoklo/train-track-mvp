import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'workout_screen.dart';

class WellnessFormScreen extends StatefulWidget {
  const WellnessFormScreen({Key? key}) : super(key: key);

  @override
  State<WellnessFormScreen> createState() => _WellnessFormScreenState();
}

class _WellnessFormScreenState extends State<WellnessFormScreen>
    with SingleTickerProviderStateMixin {
  double sleep = 3;
  double pain = 1;
  double fatigue = 3;
  double stress = 3;
  double mood = 3;

  String targetMuscleGroup = 'full_body';

  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF0F172A);

  static const List<Map<String, String>> targetOptions = [
    {'label': 'Full body', 'value': 'full_body'},
    {'label': 'Tren superior', 'value': 'tren_superior'},
    {'label': 'Tren inferior', 'value': 'tren_inferior'},
    {'label': 'Pecho', 'value': 'pecho'},
    {'label': 'Espalda', 'value': 'espalda'},
    {'label': 'Piernas', 'value': 'piernas'},
    {'label': 'Hombros', 'value': 'hombros'},
    {'label': 'Brazos', 'value': 'brazos'},
    {'label': 'Core', 'value': 'core'},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  

  Future<void> _generateWorkout() async {
    setState(() {
      isLoading = true;
    });

    try {
      final wellnessData = <String, int>{
        "sleep": sleep.round(),
        "pain": pain.round(),
        "fatigue": fatigue.round(),
        "stress": stress.round(),
        "mood": mood.round(),
      };

      final workoutData = <String, dynamic>{
        ...wellnessData,
        "targetMuscleGroup": targetMuscleGroup,
      };

      await ApiService.saveWellness(wellnessData);

      final data = await ApiService.generateWorkout(workoutData);

      if (!mounted) return;

      if (data != null) {
        final double factorCalculado =
            (data['loadFactor'] as num).toDouble();

        final List<Map<String, dynamic>> exercises =
            List<Map<String, dynamic>>.from(data['exercises']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutScreen(
              sessionId: data['sessionId'],
              loadFactor: factorCalculado,
              recommendation: data['recommendation'],
              message: data['message'] ?? '',
              exercises: exercises,
            ),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al generar la rutina. Revisa tu conexion.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al conectar con el backend. Revisa que el servidor este encendido.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.34, 0.34],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIntroCard(),

                          const SizedBox(height: 18),

                          _buildTargetMuscleCard(),

                          const SizedBox(height: 18),

                          _buildMetricCard(
                            title: 'Calidad de sueno',
                            subtitle: '1 = muy mala | 5 = excelente',
                            icon: Icons.bedtime_outlined,
                            value: sleep,
                            inverseColor: false,
                            onChanged: (val) => setState(() => sleep = val),
                          ),

                          _buildMetricCard(
                            title: 'Nivel de dolor',
                            subtitle: '1 = sin dolor | 5 = dolor alto',
                            icon: Icons.healing_outlined,
                            value: pain,
                            inverseColor: true,
                            onChanged: (val) => setState(() => pain = val),
                          ),

                          _buildMetricCard(
                            title: 'Nivel de fatiga',
                            subtitle: '1 = descansado | 5 = agotado',
                            icon: Icons.battery_2_bar_outlined,
                            value: fatigue,
                            inverseColor: true,
                            onChanged: (val) => setState(() => fatigue = val),
                          ),

                          _buildMetricCard(
                            title: 'Nivel de estres',
                            subtitle: '1 = tranquilo | 5 = muy estresado',
                            icon: Icons.psychology_alt_outlined,
                            value: stress,
                            inverseColor: true,
                            onChanged: (val) => setState(() => stress = val),
                          ),

                          _buildMetricCard(
                            title: 'Estado de animo',
                            subtitle: '1 = bajo | 5 = excelente',
                            icon: Icons.sentiment_satisfied_alt_outlined,
                            value: mood,
                            inverseColor: false,
                            onChanged: (val) => setState(() => mood = val),
                          ),

                          const SizedBox(height: 12),

                          _buildGenerateButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Registro de Bienestar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.monitor_heart,
              color: secondaryColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evalua tu estado actual',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Usa una escala del 1 al 5 y elige que quieres entrenar hoy.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetMuscleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objetivo de hoy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Elige que grupo quieres entrenar.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: targetOptions.map((option) {
              final bool isSelected = targetMuscleGroup == option['value'];

              return SizedBox(
                width: 120,
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Center(
                    child: Text(
                      option['label']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (_) {
                    setState(() {
                      targetMuscleGroup = option['value']!;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required bool inverseColor,
    required Function(double) onChanged,
  }) {
    final Color metricColor = _getDynamicColor(value, inverseColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: metricColor.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: metricColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: metricColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: metricColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  value.round().toString(),
                  style: TextStyle(
                    color: metricColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: metricColor,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: metricColor,
              overlayColor: metricColor.withOpacity(0.15),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 11,
              ),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _generateWorkout,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[400],
        padding: const EdgeInsets.symmetric(vertical: 19),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded),
                SizedBox(width: 10),
                Text(
                  'GENERAR ENTRENAMIENTO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );
  }

  Color _getDynamicColor(double value, bool inverse) {
    if (inverse) {
      if (value <= 2) return const Color(0xFF22C55E);
      if (value == 3) return const Color(0xFFF59E0B);
      return const Color(0xFFEF4444);
    } else {
      if (value >= 4) return const Color(0xFF22C55E);
      if (value == 3) return const Color(0xFFF59E0B);
      return const Color(0xFFEF4444);
    }
  }
}