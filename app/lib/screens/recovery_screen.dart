import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import '../utils/navigation_guard.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> recoveryFuture;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    recoveryFuture = ApiService.getRecoveryStatus();

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

  Future<void> _refreshRecovery() async {
    setState(() {
      recoveryFuture = ApiService.getRecoveryStatus();
    });
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Color _getStatusColor(String status, int remainingHours) {
    if (status == 'ready' || remainingHours == 0) {
      return secondaryColor;
    }

    if (remainingHours <= 24) {
      return warningColor;
    }

    return dangerColor;
  }

  IconData _getMuscleIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'pecho':
        return Icons.accessibility_new_rounded;
      case 'espalda':
        return Icons.airline_seat_flat_rounded;
      case 'piernas':
        return Icons.directions_run_rounded;
      case 'hombros':
        return Icons.fitness_center_rounded;
      case 'brazos':
        return Icons.sports_mma_rounded;
      case 'core':
        return Icons.self_improvement_rounded;
      case 'biceps':
      case 'triceps':
        return Icons.sports_mma_rounded;
      case 'gluteos':
      case 'cuadriceps':
      case 'isquios':
      case 'femorales':
      case 'pantorrillas':
        return Icons.directions_run_rounded;
      default:
        return Icons.monitor_heart_rounded;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Map<String, dynamic> _recoveryItemFor(List recovery, String muscleGroup) {
    for (final item in recovery) {
      if (item is Map && item['muscleGroup'] == muscleGroup) {
        return Map<String, dynamic>.from(item);
      }
    }

    return {
      'muscleGroup': muscleGroup,
      'status': 'ready',
      'message': 'Listo para entrenar',
      'remainingHours': 0,
      'lastTrainedAt': null,
      'lastRpe': null,
    };
  }

  String _statusText(String status, int remainingHours) {
    if (status == 'ready' || remainingHours == 0) {
      return 'Listo';
    }

    if (remainingHours <= 24) {
      return 'Casi listo';
    }

    return 'Descanso';
  }

  double _recoveryProgress(int remainingHours) {
    if (remainingHours <= 0) return 1;
    if (remainingHours >= 72) return 0;

    return 1 - (remainingHours / 72);
  }

  @override
  Widget build(BuildContext context) {
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
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: recoveryFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return _buildErrorState(
                                error: snapshot.error.toString(),
                                isDark: isDark,
                                cardColor: cardColor,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                borderColor: borderColor,
                              );
                            }

                            final data = snapshot.data;
                            final List recovery = data?['recovery'] ?? [];

                            if (recovery.isEmpty) {
                              return _buildEmptyState(
                                isDark: isDark,
                                cardColor: cardColor,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                borderColor: borderColor,
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: _refreshRecovery,
                              color: primaryColor,
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                children: [
                                  _buildSummaryCard(
                                    recovery: recovery,
                                    isDark: isDark,
                                    cardColor: cardColor,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    borderColor: borderColor,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildMuscleDashboard(
                                    recovery: recovery,
                                    isDark: isDark,
                                    cardColor: cardColor,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    borderColor: borderColor,
                                  ),
                                ],
                              ),
                            );
                          },
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
              'Descanso Muscular',
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

  Widget _buildSummaryCard({
    required List recovery,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final int readyCount = recovery.where((item) {
      final int remainingHours = _asInt(item['remainingHours']);
      final String status = item['status'] ?? '';
      return status == 'ready' || remainingHours == 0;
    }).length;

    final int restCount = recovery.length - readyCount;

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
              color: secondaryColor.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: secondaryColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de recuperacion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$readyCount grupos listos · $restCount en descanso',
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

  Widget _buildMuscleDashboard({
    required List recovery,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final groups = [
      'pecho',
      'espalda',
      'piernas',
      'hombros',
      'brazos',
      'core',
      'biceps',
      'triceps',
      'gluteos',
      'cuadriceps',
      'isquios',
      'femorales',
      'pantorrillas',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDark ? 0.22 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_customize_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel muscular',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vista rapida por grupo muscular.',
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

          const SizedBox(height: 16),

          Row(
            children: [
              _buildLegendItem(secondaryColor, 'Listo', subtitleColor),
              const SizedBox(width: 10),
              _buildLegendItem(warningColor, '< 24h', subtitleColor),
              const SizedBox(width: 10),
              _buildLegendItem(dangerColor, '+24h', subtitleColor),
            ],
          ),

          const SizedBox(height: 18),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groups.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.28,
            ),
            itemBuilder: (context, index) {
              final group = groups[index];
              final item = _recoveryItemFor(recovery, group);

              return _buildMuscleTile(
                item: item,
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleTile({
    required Map<String, dynamic> item,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final String muscleGroup = item['muscleGroup'] ?? 'grupo';
    final String status = item['status'] ?? 'ready';
    final int remainingHours = _asInt(item['remainingHours']);
    final dynamic lastRpe = item['lastRpe'];

    final Color statusColor = _getStatusColor(status, remainingHours);
    final double progress = _recoveryProgress(remainingHours);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? statusColor.withOpacity(0.12)
            : statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withOpacity(isDark ? 0.45 : 0.35),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(isDark ? 0.20 : 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _getMuscleIcon(muscleGroup),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF020617).withOpacity(0.85)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  remainingHours == 0 ? 'OK' : '${remainingHours}h',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            _capitalize(muscleGroup),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _statusText(status, remainingHours),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.8),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          if (lastRpe != null) ...[
            const SizedBox(height: 7),
            Text(
              'Ultimo RPE: $lastRpe',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: subtitleColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                size: 56,
                color: primaryColor,
              ),
              const SizedBox(height: 18),
              Text(
                'Sin datos de recuperacion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cuando finalices entrenamientos y registres RPE, aparecera aqui tu descanso muscular.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtitleColor,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String error,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : dangerColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: dangerColor,
              ),
              const SizedBox(height: 18),
              Text(
                'Error al cargar recuperacion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _refreshRecovery,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
