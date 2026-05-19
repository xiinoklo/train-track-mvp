import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import 'wellness_form_screen.dart';
import 'history_screen.dart';
import 'recovery_screen.dart';
import 'profile_screen.dart';
import 'admin_panel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAdmin = false;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color adminColor = Color(0xFF7C3AED);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
    _loadAdminState();
  }

  Future<void> _loadAdminState() async {
    final admin = await ApiService.isAdmin();

    if (!mounted) return;

    setState(() {
      _isAdmin = admin;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToWellnessForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WellnessFormScreen(),
      ),
    );
  }

  void _goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }

  void _goToRecovery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecoveryScreen(),
      ),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void _goToAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPanelScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;

        final Color pageBottomColor =
            isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);

        final Color cardColor =
            isDark ? const Color(0xFF0F172A) : Colors.white;

        final Color cardTextColor =
            isDark ? Colors.white : darkText;

        final Color mutedTextColor =
            isDark ? Colors.white70 : Colors.grey;

        final Color footerColor = isDark
            ? const Color(0xFF0F172A).withOpacity(0.90)
            : Colors.white.withOpacity(0.82);

        final Color footerTextColor =
            isDark ? Colors.white : darkText;

        return Scaffold(
          backgroundColor: pageBottomColor,
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
                stops: const [0.0, 0.42, 0.42],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _buildLogoBadge(),
                            const Spacer(),
                            _buildThemeButton(),
                            const SizedBox(width: 10),
                            _buildProfileButton(),
                          ],
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Entrena inteligente,\nno más fuerte.',
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Registra tu bienestar diario, genera rutinas ajustadas y controla tu recuperación muscular.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 34),

                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.transparent,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.28 : 0.12,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: secondaryColor.withOpacity(
                                          isDark ? 0.18 : 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Icons.monitor_heart,
                                        color: secondaryColor,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Panel de entrenamiento',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: cardTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Bienestar, historial y descanso muscular.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: mutedTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 26),

                                ElevatedButton.icon(
                                  onPressed: _goToWellnessForm,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Registrar Bienestar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 0,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                OutlinedButton.icon(
                                  onPressed: _goToHistory,
                                  icon: const Icon(Icons.history),
                                  label: const Text('Ver Historial'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        isDark ? Colors.white : primaryColor,
                                    side: BorderSide(
                                      color:
                                          isDark ? Colors.white70 : primaryColor,
                                      width: 1.4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                OutlinedButton.icon(
                                  onPressed: _goToRecovery,
                                  icon: const Icon(
                                    Icons.health_and_safety_rounded,
                                  ),
                                  label: const Text('Descanso Muscular'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: warningColor,
                                    side: const BorderSide(
                                      color: warningColor,
                                      width: 1.4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),

                                if (_isAdmin) ...[
                                  const SizedBox(height: 14),
                                  OutlinedButton.icon(
                                    onPressed: _goToAdminPanel,
                                    icon: const Icon(
                                      Icons.admin_panel_settings_rounded,
                                    ),
                                    label: const Text('Panel Admin'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: adminColor,
                                      side: const BorderSide(
                                        color: adminColor,
                                        width: 1.4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: footerColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: isDark ? Colors.white : primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'La carga y el descanso se ajustan según tu estado y sesiones recientes.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: footerTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
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

  Widget _buildLogoBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
            ),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'TrainTrack',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeButton() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;

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
      },
    );
  }

  Widget _buildProfileButton() {
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
        onPressed: _goToProfile,
        icon: const Icon(Icons.person_rounded),
        color: Colors.white,
        tooltip: 'Mi perfil',
      ),
    );
  }
}