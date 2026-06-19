import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import 'dashboard_screen.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();

  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El username debe tener al menos 3 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usa solo letras, numeros y guion bajo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final success = await ApiService.updateProfile(username: username);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el username. Puede estar en uso.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark;

        final Color pageBackground = isDark ? darkBackground : lightBackground;

        final Color cardColor = isDark ? darkCard : Colors.white;

        final Color titleColor = isDark ? Colors.white : darkText;

        final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[600]!;

        final Color inputFillColor = isDark
            ? const Color(0xFF111827)
            : Colors.white;

        final Color inputBorderColor = isDark
            ? Colors.white.withValues(alpha: 0.18)
            : const Color(0xFFCBD5E1);

        final Color iconBackgroundColor = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : primaryColor.withValues(alpha: 0.1);

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
                stops: const [0.0, 0.42, 0.42],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Crea tu perfil',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            _buildThemeButton(isDark),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Elige un nombre de usuario para mostrar en tu perfil de TrainTrack.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),

                        const SizedBox(height: 36),

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
                                  alpha: isDark ? 0.35 : 0.12,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: iconBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: primaryColor,
                                  size: 54,
                                ),
                              ),

                              const SizedBox(height: 22),

                              Text(
                                'Elige tu username',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: titleColor,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Este nombre aparecerá en tu perfil.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 24),

                              TextField(
                                controller: _usernameController,
                                enabled: !isLoading,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _saveUsername(),
                                style: TextStyle(color: titleColor),
                                decoration: InputDecoration(
                                  labelText: 'Nombre de usuario',
                                  hintText: 'ej: benja_fit',
                                  labelStyle: TextStyle(color: subtitleColor),
                                  hintStyle: TextStyle(
                                    color: subtitleColor.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.alternate_email,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[700],
                                  ),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: inputBorderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 1.8,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: inputBorderColor,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                'Puedes usar letras, numeros y guion bajo.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _saveUsername,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: secondaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: secondaryColor
                                        .withValues(alpha: 0.55),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'CONTINUAR',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
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

  Widget _buildThemeButton(bool isDark) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: IconButton(
        onPressed: AppThemeController.toggleTheme,
        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        color: Colors.white,
        tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
      ),
    );
  }
}
