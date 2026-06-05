import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import '../utils/navigation_guard.dart';
import 'workout_summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final String sessionId;
  final double loadFactor;
  final String recommendation;
  final String message;
  final List<Map<String, dynamic>> exercises;
  final bool canCustomizeWorkout;

  const WorkoutScreen({
    Key? key,
    required this.sessionId,
    required this.loadFactor,
    required this.recommendation,
    required this.message,
    required this.exercises,
    this.canCustomizeWorkout = false,
  }) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Map<String, dynamic>> _exercises;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    _exercises = widget.exercises
        .map((exercise) => Map<String, dynamic>.from(exercise))
        .toList();

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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  List<Map<String, dynamic>> get _exercisesForSave {
    return _exercises
        .map((exercise) => Map<String, dynamic>.from(exercise))
        .toList();
  }

  List<String> get _trainedMuscleGroups {
    final groups = <String>{};

    for (final exercise in _exercisesForSave) {
      final group = exercise['muscleGroup']?.toString().trim();

      if (group != null && group.isNotEmpty && group != 'null') {
        groups.add(group);
      }
    }

    return groups.toList();
  }

  Color get _sessionColor {
    if (widget.loadFactor == 0) return dangerColor;
    if (widget.loadFactor == 0.5) return warningColor;
    return secondaryColor;
  }

  IconData get _sessionIcon {
    if (widget.loadFactor == 0) return Icons.self_improvement_rounded;
    if (widget.loadFactor == 0.5) return Icons.speed_rounded;
    return Icons.bolt_rounded;
  }

  // true = hay sesión real en BD; false = todos los músculos en descanso (sessionId vacío)
  bool get _hasSession => widget.sessionId.isNotEmpty;

  void _showVideoModal(BuildContext context, String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video no disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoPlayerModal(videoUrl: videoUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRestDay = _exercises.isEmpty;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;

        final Color pageBackground =
            isDark ? darkBackground : lightBackground;

        final Color cardColor = isDark ? darkCard : Colors.white;

        final Color titleColor = isDark ? Colors.white : darkText;

        final Color subtitleColor =
            isDark ? Colors.white70 : Colors.grey[700]!;

        final Color borderColor =
            isDark ? Colors.white.withOpacity(0.08) : Colors.transparent;

        return Scaffold(
          backgroundColor: pageBackground,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF020617),
                        Color(0xFF1E3A8A),
                        Color(0xFF020617),
                      ]
                    : const [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFFF8FAFC),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.34, 0.34],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(context, isDark),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRecommendationCard(
                                isDark: isDark,
                                cardColor: cardColor,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                borderColor: borderColor,
                              ),
                              const SizedBox(height: 18),
                              if (isRestDay)
                                _buildRestMessage(
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                )
                              else ...[
                                _buildWorkoutSummary(
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 18),
                                if (widget.canCustomizeWorkout)
                                  _buildCustomizeHint(
                                    isDark: isDark,
                                    cardColor: cardColor,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    borderColor: borderColor,
                                  ),
                                if (widget.canCustomizeWorkout)
                                  const SizedBox(height: 18),
                                ..._exercises.asMap().entries.map(
                                  (entry) => _buildExerciseCard(
                                    index: entry.key,
                                    exercise: entry.value,
                                    isDark: isDark,
                                    cardColor: cardColor,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    borderColor: borderColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_hasSession) _buildFinishButton(context),
                              ],
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
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 18, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => popIfPossible(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Rutina del Día',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ),
          _buildThemeButton(isDark),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final Color color = _sessionColor;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
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
              color: color.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _sessionIcon,
              color: color,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recommendation,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummary({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final int totalExercises = _exercises.length;
    final int totalSets = _exercises.fold<int>(
      0,
      (sum, exercise) => sum + _asInt(exercise['sets']),
    );

    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.fitness_center_rounded,
            label: 'Ejercicios',
            value: totalExercises.toString(),
            color: primaryColor,
            isDark: isDark,
            cardColor: cardColor,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.format_list_numbered_rounded,
            label: 'Series',
            value: totalSets.toString(),
            color: secondaryColor,
            isDark: isDark,
            cardColor: cardColor,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.tune_rounded,
            label: 'Carga',
            value: widget.loadFactor == 1 ? '100%' : '50%',
            color: _sessionColor,
            isDark: isDark,
            cardColor: cardColor,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestMessage({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dangerColor.withOpacity(isDark ? 0.35 : 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: dangerColor.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _hasSession
                  ? Icons.self_improvement_rounded
                  : Icons.bed_rounded,
              size: 58,
              color: dangerColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _hasSession
                ? 'Descanso activo / recuperación'
                : 'Músculos en descanso',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _hasSession
                ? 'Hoy no se recomienda una rutina de fuerza. Prioriza movilidad suave, caminata ligera o recuperación.'
                : 'Todos los músculos que seleccionaste aún están en período de recuperación. Respeta el descanso para rendir mejor.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () => popIfPossible(context),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Volver al inicio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : primaryColor,
              side: BorderSide(
                color: isDark ? Colors.white70 : primaryColor,
                width: 1.4,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizeHint({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: warningColor.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: warningColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutina editable',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajusta series, repeticiones y peso antes de finalizar.',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateExerciseField(int index, String field, dynamic value) {
    setState(() {
      _exercises[index][field] = value;
    });
  }

  void _changeSets(int index, int delta) {
    final currentSets = _asInt(_exercises[index]['sets']);
    final nextSets = (currentSets + delta).clamp(1, 8);
    _updateExerciseField(index, 'sets', nextSets);
  }

  Widget _buildExerciseCard({
    required int index,
    required Map<String, dynamic> exercise,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final String name = exercise['name'] ?? 'Ejercicio';
    final String muscleGroup = exercise['muscleGroup'] ?? 'General';
    final int sets = _asInt(exercise['sets']);
    final String reps = exercise['reps']?.toString() ?? '-';
    final String weight = exercise['weight']?.toString() ?? '';
    final String instructions = exercise['instructions'] ?? '';
    final String? videoUrl = exercise['videoUrl'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.045),
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
                  color: primaryColor.withOpacity(isDark ? 0.22 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDark ? 0.20 : 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  muscleGroup,
                  style: TextStyle(
                    color: isDark ? Colors.white : primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : lightBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.repeat_rounded,
                  color: secondaryColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  '$sets series',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 18,
                  color: isDark
                      ? Colors.white.withOpacity(0.16)
                      : Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$reps reps',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.canCustomizeWorkout) ...[
            const SizedBox(height: 14),
            _buildEditableTrainingControls(
              index: index,
              sets: sets,
              reps: reps,
              weight: weight,
              isDark: isDark,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            instructions,
            style: TextStyle(
              color: subtitleColor,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          if (videoUrl != null && videoUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _showVideoModal(context, videoUrl),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          YoutubePlayer.getThumbnail(
                            videoId:
                                YoutubePlayer.convertUrlToId(videoUrl) ?? '',
                          ),
                          width: double.infinity,
                          height: 170,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: double.infinity,
                            height: 170,
                            color: isDark
                                ? const Color(0xFF111827)
                                : Colors.grey[200],
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 50,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 170,
                          color: Colors.black.withOpacity(0.35),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: dangerColor.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: dangerColor.withOpacity(isDark ? 0.20 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: dangerColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '¿Tienes dudas? Mira el tutorial',
                        style: TextStyle(
                          color: dangerColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableTrainingControls({
    required int index,
    required int sets,
    required String reps,
    required String weight,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final Color fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Series',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: () => _changeSets(index, -1),
                icon: const Icon(Icons.remove_rounded),
                constraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 38,
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  sets.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _changeSets(index, 1),
                icon: const Icon(Icons.add_rounded),
                constraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: reps,
                  style: TextStyle(color: titleColor),
                  decoration: InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(color: subtitleColor),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                  ),
                  onChanged: (value) =>
                      _updateExerciseField(index, 'reps', value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: weight,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: titleColor),
                  decoration: InputDecoration(
                    labelText: 'Peso kg',
                    labelStyle: TextStyle(color: subtitleColor),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                  ),
                  onChanged: (value) =>
                      _updateExerciseField(index, 'weight', value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _mostrarDialogoRPE(context),
      icon: const Icon(Icons.check_circle_outline_rounded),
      label: const Text(
        'FINALIZAR ENTRENAMIENTO',
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 19),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }

  void _mostrarDialogoRPE(BuildContext context) {
    double rpe = 5;
    bool isSaving = false;

    final bool isDark = AppThemeController.themeMode.value == ThemeMode.dark;

    final Color dialogColor = isDark ? darkCard : Colors.white;
    final Color titleColor = isDark ? Colors.white : darkText;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              title: Text(
                'Registrar RPE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Qué tan exigente fue el entrenamiento?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(isDark ? 0.22 : 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      rpe.round().toString(),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Slider(
                    value: rpe,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: primaryColor,
                    label: rpe.round().toString(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setDialogState(() {
                              rpe = value;
                            });
                          },
                  ),
                  Text(
                    '1 = muy fácil | 10 = máximo esfuerzo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final result = await ApiService.registerRpe(
                              sessionId: widget.sessionId,
                              rpe: rpe.round(),
                              exercises: widget.canCustomizeWorkout
                                  ? _exercisesForSave
                                  : null,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            final int xpGained =
                                _asInt(result['xpGained']);
                            final userProgress =
                                Map<String, dynamic>.from(
                              result['userProgress'] ?? {},
                            );

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutSummaryScreen(
                                  xpGained: xpGained,
                                  userProgress: userProgress,
                                  exercises: _exercisesForSave,
                                  trainedMuscleGroups: _trainedMuscleGroups,
                                  recommendation: widget.recommendation,
                                  loadFactor: widget.loadFactor,
                                ),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error al guardar RPE en el backend.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeButton(bool isDark) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: IconButton(
        onPressed: AppThemeController.toggleTheme,
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        ),
        color: Colors.white,
        tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
      ),
    );
  }
}

class _VideoPlayerModal extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerModal({required this.videoUrl});

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  late YoutubePlayerController _ytController;

  static const Color dangerColor = Color(0xFFEF4444);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    _ytController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideThumbnail: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.pause();
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;

        final Color modalColor = isDark ? darkCard : Colors.white;
        final Color titleColor = isDark ? Colors.white : darkText;
        final Color handleColor =
            isDark ? Colors.white.withOpacity(0.18) : Colors.grey[300]!;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: modalColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Tutorial del Ejercicio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: YoutubePlayer(
                    controller: _ytController,
                    showVideoProgressIndicator: true,
                    progressColors: const ProgressBarColors(
                      playedColor: dangerColor,
                      handleColor: dangerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
