import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import '../utils/navigation_guard.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>?> profileFuture;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    profileFuture = ApiService.getProfile();

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

  String _getRankFromLevel(int level) {
    final int safeLevel = level.clamp(1, 9).toInt();
    final subLevel = ((safeLevel - 1) % 3) + 1;

    if (safeLevel <= 3) return 'Principiante $subLevel';
    if (safeLevel <= 6) return 'Intermedio $subLevel';
    return 'Avanzado $subLevel';
  }

  String _displayValue(dynamic value, String fallback) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('is_admin');
    await prefs.remove('admin_jwt_token');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
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
            isDark ? Colors.white70 : Colors.grey[600]!;

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
                        child: FutureBuilder<Map<String, dynamic>?>(
                          future: profileFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (snapshot.hasError || snapshot.data == null) {
                              return _buildErrorState(
                                isDark: isDark,
                                cardColor: cardColor,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                borderColor: borderColor,
                              );
                            }

                            final Map<String, dynamic> response =
                                snapshot.data!;

                            final Map<String, dynamic> user =
                                Map<String, dynamic>.from(
                              response['user'] ?? {},
                            );

                            return ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              children: [
                                _buildProfileCard(
                                  user: user,
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 18),
                                _buildProgressCard(
                                  user: user,
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 18),
                                _buildUserInfoCard(
                                  user: user,
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 24),
                                _buildLogoutButton(context),
                              ],
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
              'Mi Perfil',
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

  Widget _buildProfileCard({
    required Map<String, dynamic> user,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final String username = _displayValue(user['username'], 'Usuario');
    final String email = _displayValue(user['email'], 'correo@email.com');

    final int level = _asInt(user['level']) == 0 ? 1 : _asInt(user['level']);
    final String rank = _displayValue(
      user['rank'],
      _getRankFromLevel(level),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : primaryColor.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 56,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            username,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(isDark ? 0.20 : 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Rango: $rank',
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rank,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required Map<String, dynamic> user,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final int level = _asInt(user['level']) == 0 ? 1 : _asInt(user['level']);
    final int xp = _asInt(user['xp']);
    final int xpGoal =
        _asInt(user['xpGoal']) == 0 ? 100 : _asInt(user['xpGoal']);

    final int xpInCurrentLevel = user['xpInCurrentLevel'] != null
        ? _asInt(user['xpInCurrentLevel'])
        : xp % xpGoal;

    final double progress =
        xpGoal == 0 ? 0 : (xpInCurrentLevel / xpGoal).clamp(0.0, 1.0);

    final int remainingXp = (xpGoal - xpInCurrentLevel).clamp(0, xpGoal);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMiniCard(
                title: 'Nivel',
                value: '$level',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
              const SizedBox(width: 10),
              _buildMiniCard(
                title: 'XP',
                value: '$xpInCurrentLevel/$xpGoal',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor:
                  isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            remainingXp == 0
                ? 'Ya puedes subir al siguiente nivel'
                : 'Te faltan $remainingXp XP para subir al siguiente nivel',
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard({
    required Map<String, dynamic> user,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    final String experienceLevel = _displayValue(
      user['experienceLevel'],
      'Sin definir',
    );

    final String mainGoal = _displayValue(
      user['mainGoal'],
      'Sin definir',
    );

    final String gender = _displayValue(
      user['gender'],
      'Sin definir',
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos del usuario',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            icon: Icons.fitness_center_rounded,
            title: 'Experiencia',
            value: experienceLevel,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.flag_rounded,
            title: 'Objetivo',
            value: mainGoal,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _StatRow(
            icon: Icons.person_outline_rounded,
            title: 'Genero',
            value: gender,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required String title,
    required String value,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.10)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _logout(context),
      icon: const Icon(Icons.logout_rounded, color: Colors.white),
      label: const Text(
        'CERRAR SESIÓN',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: dangerColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildErrorState({
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
                  : Colors.red.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 18),
              Text(
                'No se pudo cargar el perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Revisa tu conexion o vuelve a iniciar sesion.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    profileFuture = ApiService.getProfile();
                  });
                },
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

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _StatRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1E3A8A);
    const Color secondaryColor = Color(0xFF22C55E);
    const Color darkText = Color(0xFF0F172A);

    final Color titleColor = isDark ? Colors.white : darkText;
    final Color valueColor = secondaryColor;
    final Color iconBackgroundColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFDBEAFE);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
