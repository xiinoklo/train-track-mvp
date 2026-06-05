import 'package:flutter/material.dart';
import '../theme/app_theme_controller.dart';
import '../utils/navigation_guard.dart';
import '../widgets/app_card.dart';
import 'dashboard_screen.dart';
import 'recovery_screen.dart';

class WorkoutBlockedScreen extends StatelessWidget {
  final String targetMuscleGroup;
  final List<Map<String, dynamic>> blockedMuscles;
  final String? message;

  const WorkoutBlockedScreen({
    Key? key,
    required this.targetMuscleGroup,
    required this.blockedMuscles,
    this.message,
  }) : super(key: key);

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkText = Color(0xFF0F172A);

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  String _formatTarget(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color: dangerColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Icons.health_and_safety_rounded,
                                        color: dangerColor,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Descanso obligatorio',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: titleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Objetivo: ${_formatTarget(targetMuscleGroup)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: dangerColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  message ??
                                      'Como principiante, no puedes volver a entrenar un grupo muscular con mas de 24 horas de descanso pendiente.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
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
                                  'Grupos en descanso',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ...blockedMuscles.map((item) {
                                  final muscle =
                                      item['muscleGroup']?.toString() ??
                                          'Grupo muscular';
                                  final hours = _asInt(item['remainingHours']);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 13,
                                    ),
                                    decoration: BoxDecoration(
                                      color: dangerColor.withOpacity(
                                        isDark ? 0.16 : 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: dangerColor.withOpacity(0.24),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_rounded,
                                          color: dangerColor,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            muscle,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: titleColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              isDark ? 0.10 : 0.92,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '${hours}h',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: dangerColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            isDark: isDark,
                            color: isDark
                                ? const Color(0xFF111827)
                                : const Color(0xFFFFFBEB),
                            borderColor: warningColor.withOpacity(0.20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.directions_walk_rounded,
                                  color: warningColor,
                                  size: 30,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Puedes hacer movilidad, caminata suave o entrenar un grupo que aparezca como listo.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.35,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.88)
                                          : const Color(0xFF78350F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RecoveryScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shield_rounded),
                            label: const Text('Ver descanso muscular'),
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
                          TextButton(
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
                            child: const Text('Volver al inicio'),
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
          IconButton(
            onPressed: () => popIfPossible(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Entrenamiento bloqueado',
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
