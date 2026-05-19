import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> historyFuture;

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

    historyFuture = ApiService.getWellnessHistory();

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

  Future<void> _refreshHistory() async {
    setState(() {
      historyFuture = ApiService.getWellnessHistory();
    });
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Color _getMetricColor(String key, int value) {
    final bool inverse = key == 'pain' || key == 'fatigue' || key == 'stress';

    if (inverse) {
      if (value <= 2) return secondaryColor;
      if (value == 3) return warningColor;
      return dangerColor;
    } else {
      if (value >= 4) return secondaryColor;
      if (value == 3) return warningColor;
      return dangerColor;
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return 'Sin fecha';

    try {
      final date = DateTime.parse(rawDate).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year · $hour:$minute';
    } catch (_) {
      return rawDate;
    }
  }

  double _calculateAverage(List entries, String key) {
    if (entries.isEmpty) return 0;

    final total = entries.fold<int>(
      0,
      (sum, entry) => sum + _asInt(entry[key]),
    );

    return total / entries.length;
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
                          future: historyFuture,
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
                            final List entries = data?['wellnessEntries'] ?? [];

                            if (entries.isEmpty) {
                              return _buildEmptyState(
                                isDark: isDark,
                                cardColor: cardColor,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                borderColor: borderColor,
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: _refreshHistory,
                              color: primaryColor,
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                children: [
                                  _buildSummaryCard(
                                    entries: entries,
                                    isDark: isDark,
                                    cardColor: cardColor,
                                    titleColor: titleColor,
                                    subtitleColor: subtitleColor,
                                    borderColor: borderColor,
                                  ),
                                  const SizedBox(height: 18),
                                  ...entries.reversed.map(
                                    (entry) => _buildHistoryCard(
                                      entry: entry,
                                      isDark: isDark,
                                      cardColor: cardColor,
                                      titleColor: titleColor,
                                      subtitleColor: subtitleColor,
                                      borderColor: borderColor,
                                    ),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Historial de Bienestar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
          _buildThemeButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required List entries,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final double sleepAverage = _calculateAverage(entries, 'sleep');
    final double painAverage = _calculateAverage(entries, 'pain');
    final double fatigueAverage = _calculateAverage(entries, 'fatigue');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDark ? 0.22 : 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: primaryColor,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entries.length} registros guardados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Resumen general de tus últimos registros.',
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
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildAverageItem(
                  label: 'Sueño',
                  value: sleepAverage,
                  icon: Icons.bedtime_outlined,
                  color: _getMetricColor('sleep', sleepAverage.round()),
                  isDark: isDark,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAverageItem(
                  label: 'Dolor',
                  value: painAverage,
                  icon: Icons.healing_outlined,
                  color: _getMetricColor('pain', painAverage.round()),
                  isDark: isDark,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAverageItem(
                  label: 'Fatiga',
                  value: fatigueAverage,
                  icon: Icons.battery_2_bar_outlined,
                  color: _getMetricColor('fatigue', fatigueAverage.round()),
                  isDark: isDark,
                  subtitleColor: subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAverageItem({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : lightBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required dynamic entry,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final int sleep = _asInt(entry['sleep']);
    final int pain = _asInt(entry['pain']);
    final int fatigue = _asInt(entry['fatigue']);
    final int stress = _asInt(entry['stress']);
    final int mood = _asInt(entry['mood']);

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
                  Icons.monitor_heart_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Registro diario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatDate(entry['createdAt']),
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _buildMetricRow(
            label: 'Sueño',
            value: sleep,
            icon: Icons.bedtime_outlined,
            color: _getMetricColor('sleep', sleep),
            isDark: isDark,
            titleColor: titleColor,
          ),
          _buildMetricRow(
            label: 'Dolor',
            value: pain,
            icon: Icons.healing_outlined,
            color: _getMetricColor('pain', pain),
            isDark: isDark,
            titleColor: titleColor,
          ),
          _buildMetricRow(
            label: 'Fatiga',
            value: fatigue,
            icon: Icons.battery_2_bar_outlined,
            color: _getMetricColor('fatigue', fatigue),
            isDark: isDark,
            titleColor: titleColor,
          ),
          _buildMetricRow(
            label: 'Estrés',
            value: stress,
            icon: Icons.psychology_alt_outlined,
            color: _getMetricColor('stress', stress),
            isDark: isDark,
            titleColor: titleColor,
          ),
          _buildMetricRow(
            label: 'Ánimo',
            value: mood,
            icon: Icons.sentiment_satisfied_alt_outlined,
            color: _getMetricColor('mood', mood),
            isDark: isDark,
            titleColor: titleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value / 5,
                minHeight: 8,
                backgroundColor:
                    isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDark ? 0.22 : 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 56,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Aún no hay registros',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cuando registres tu bienestar diario, aparecerá aquí tu historial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: subtitleColor,
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
                'Error al cargar historial',
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
                onPressed: _refreshHistory,
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