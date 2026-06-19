import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordHidden = true;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _doLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa email y contrasena'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.login(email, pass);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas o error de red'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToRegister() {
    if (_isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
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
            : Colors.grey;

        final Color iconColor = isDark ? Colors.white70 : Colors.grey;

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
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 18,
                    child: _buildThemeButton(isDark),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Container(
                        padding: const EdgeInsets.all(26),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/traintrack_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'TrainTrack',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                                letterSpacing: 0,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Inicia sesion para continuar',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 30),

                            TextField(
                              controller: _emailController,
                              enabled: !_isLoading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: titleColor),
                              decoration: InputDecoration(
                                labelText: 'Correo electronico',
                                labelStyle: TextStyle(color: subtitleColor),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: iconColor,
                                ),
                                filled: true,
                                fillColor: inputFillColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1.8,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              enabled: !_isLoading,
                              obscureText: _isPasswordHidden,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _doLogin(),
                              style: TextStyle(color: titleColor),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(color: subtitleColor),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: iconColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordHidden
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: iconColor,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _isPasswordHidden =
                                                !_isPasswordHidden;
                                          });
                                        },
                                ),
                                filled: true,
                                fillColor: inputFillColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1.8,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: inputBorderColor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _doLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: secondaryColor
                                      .withValues(alpha: 0.55),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'INICIAR SESIÓN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: _isLoading ? null : _goToRegister,
                              child: Text(
                                '¿No tienes cuenta? Regístrate aquí',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : primaryColor,
                                ),
                              ),
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
