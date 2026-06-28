import 'package:flutter/material.dart';

import '../services/video_preload_service.dart';
import '../theme/app_theme_controller.dart';
import 'wellness_form_screen.dart';

class VideoPreloadScreen extends StatefulWidget {
  const VideoPreloadScreen({super.key});

  @override
  State<VideoPreloadScreen> createState() => _VideoPreloadScreenState();
}

class _VideoPreloadScreenState extends State<VideoPreloadScreen> {
  int _completed = 0;
  int _total = 0;
  String _status = 'Buscando tutoriales';
  String _detail = 'Preparando tu entrenamiento';
  bool _isReady = false;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _prepareVideos();
  }

  Future<void> _prepareVideos() async {
    try {
      final result = await VideoPreloadService.prepareExerciseVideos(
        onProgress: (completed, total) {
          if (!mounted) return;

          setState(() {
            _completed = completed;
            _total = total;
            _status = total == 0
                ? 'Verificando catálogo'
                : 'Preparando tutoriales';
            _detail = total == 0
                ? 'Revisando ejercicios disponibles'
                : '$completed de $total videos listos';
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _completed = result.videoCount;
        _total = result.videoCount;
        _isReady = true;
        _status = result.failedThumbnailCount > 0
            ? 'Continuamos con conexión'
            : 'Tutoriales listos';
        _detail = result.missingVideoCount > 0
            ? '${result.missingVideoCount} ejercicios quedan sin video'
            : 'Entramos a tu registro diario';
      });

      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WellnessFormScreen()),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _status = 'Abriendo bienestar';
        _detail = 'Podrás entrenar igual';
      });

      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WellnessFormScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final pageBackground = isDark ? darkBackground : lightBackground;
        final cardColor = isDark ? darkCard : Colors.white;
        final titleColor = isDark ? Colors.white : darkText;
        final subtitleColor = isDark ? Colors.white70 : Colors.grey[600]!;
        final double? progress = _total == 0
            ? null
            : (_completed / _total).clamp(0.0, 1.0).toDouble();
        final percentText = progress == null
            ? '...'
            : '${(progress * 100).round()}%';

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
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBrandHeader(),
                        const SizedBox(height: 26),
                        Text(
                          'Preparando tu sesión',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Dejamos los tutoriales listos antes de tu bienestar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.transparent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.35 : 0.16,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 118,
                                height: 118,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 9,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.10)
                                          : const Color(0xFFE2E8F0),
                                      color: _isReady
                                          ? secondaryColor
                                          : primaryColor,
                                    ),
                                    Center(
                                      child: Text(
                                        percentText,
                                        style: TextStyle(
                                          color: titleColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                _status,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _detail,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 22),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 9,
                                  value: progress,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : const Color(0xFFE2E8F0),
                                  color: _isReady
                                      ? secondaryColor
                                      : primaryColor,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _buildStatusRow(
                                icon: Icons.fitness_center_rounded,
                                label: 'Ejercicios',
                                value: _total == 0 ? 'Revisando' : 'OK',
                                color: primaryColor,
                                isDark: isDark,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusRow(
                                icon: Icons.play_circle_rounded,
                                label: 'Videos',
                                value: _total == 0
                                    ? 'Pendiente'
                                    : '$_completed/$_total',
                                color: warningColor,
                                isDark: isDark,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusRow(
                                icon: _isReady
                                    ? Icons.check_circle_rounded
                                    : Icons.hourglass_top_rounded,
                                label: 'Bienestar',
                                value: _isReady ? 'Listo' : 'En espera',
                                color: _isReady
                                    ? secondaryColor
                                    : subtitleColor,
                                isDark: isDark,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandHeader() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'TrainTrack',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.20 : 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
