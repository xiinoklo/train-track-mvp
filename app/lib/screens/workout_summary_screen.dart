import 'package:flutter/material.dart';
import '../theme/app_theme_controller.dart';
import '../widgets/app_card.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int xpGained;
  final Map<String, dynamic> userProgress;
  final List<Map<String, dynamic>> exercises;
  final List<String> trainedMuscleGroups;
  final String recommendation;
  final double loadFactor;

  const WorkoutSummaryScreen({
    Key? key,
    required this.xpGained,
    required this.userProgress,
    required this.exercises,
    required this.trainedMuscleGroups,
    required this.recommendation,
    required this.loadFactor,
  }) : super(key: key);

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkText = Color(0xFF0F172A);

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  String _rankFromLevel(int level) {
    final safeLevel = level.clamp(1, 9).toInt();
    final subLevel = ((safeLevel - 1) % 3) + 1;

    if (safeLevel <= 3) return 'Principiante $subLevel';
    if (safeLevel <= 6) return 'Intermedio $subLevel';
    return 'Avanzado $subLevel';
  }

  String _loadLabel() {
    if (loadFactor == 1) return 'Carga normal';
    if (loadFactor == 0.5) return 'Carga reducida';
    return 'Recuperacion';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;
        final Color titleColor = isDark ? Colors.white : darkText;
        final Color subtitleColor =
            isDark ? Colors.white70 : Colors.grey[700]!;
        final int level = _asInt(userProgress['level']);
        final int xp = _asInt(userProgress['xp']);
        final int xpInLevel = _asInt(userProgress['xpInLevel']);
        final int xpNeeded = _asInt(userProgress['xpNeeded']);
        final String rank =
            userProgress['rank']?.toString().trim().isNotEmpty == true
                ? userProgress['rank'].toString()
                : _rankFromLevel(level == 0 ? 1 : level);
        final double progressValue = xpNeeded <= 0
            ? 1.0
            : (xpInLevel / xpNeeded).clamp(0.0, 1.0).toDouble();

        return Scaffold(
          backgroundColor: isDark ? darkBackground : lightBackground,
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
                stops: const [0.0, 0.30, 0.30],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  Expanded(
                    child: _AnimatedPageContent(
                      child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color:
                                            secondaryColor.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: secondaryColor,
                                        size: 34,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Entrenamiento finalizado',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: titleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            recommendation,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MetricTile(
                                        title: 'XP ganada',
                                        value: '+$xpGained',
                                        isDark: isDark,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _MetricTile(
                                        title: 'Nivel',
                                        value: '${level == 0 ? 1 : level}',
                                        isDark: isDark,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  rank,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 9,
                                    color: secondaryColor,
                                    backgroundColor: isDark
                                        ? Colors.white.withOpacity(0.10)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  xpNeeded <= 0
                                      ? '$xp XP acumulada'
                                      : '$xpInLevel/$xpNeeded XP hacia el siguiente nivel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumen de rutina',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _SummaryRow(
                                  icon: Icons.fitness_center_rounded,
                                  label: 'Ejercicios',
                                  value: '${exercises.length}',
                                  isDark: isDark,
                                ),
                                _SummaryRow(
                                  icon: Icons.speed_rounded,
                                  label: 'Intensidad',
                                  value: _loadLabel(),
                                  isDark: isDark,
                                ),
                                _SummaryRow(
                                  icon: Icons.grid_view_rounded,
                                  label: 'Grupos',
                                  value: trainedMuscleGroups.isEmpty
                                      ? 'Sin datos'
                                      : trainedMuscleGroups.join(', '),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Ir al inicio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_rounded),
                            label: const Text('Ver progreso'),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Resumen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            onPressed: AppThemeController.toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPageContent extends StatelessWidget {
  final Widget child;

  const _AnimatedPageContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;
  final Color color;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
