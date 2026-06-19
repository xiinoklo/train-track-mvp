import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import '../utils/navigation_guard.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = 'Masculino';
  String _selectedExperience = 'principiante';
  String _selectedGoal = 'Salud y bienestar';

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
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final ageStr = _ageController.text.trim();

    if (email.isEmpty || pass.isEmpty || ageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final age = int.tryParse(ageStr);

    if (age == null || age < 10 || age > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una edad válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.registerUser(
      email: email,
      password: pass,
      age: age,
      gender: _selectedGender,
      experienceLevel: _selectedExperience,
      mainGoal: _selectedGoal,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error en el registro. El correo podría estar en uso.'),
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
                stops: const [0.0, 0.38, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 18, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _isLoading
                              ? null
                              : () => popIfPossible(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _buildThemeButton(isDark),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      child: Container(
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
                                alpha: isDark ? 0.35 : 0.14,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: primaryColor,
                                size: 46,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              'Unete a TrainTrack',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Crea tu cuenta y configura tu perfil inicial.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 28),

                            _buildSectionTitle('Datos de acceso', titleColor),

                            const SizedBox(height: 12),

                            TextField(
                              controller: _emailController,
                              enabled: !_isLoading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: titleColor),
                              decoration: _inputDecoration(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                isDark: isDark,
                                subtitleColor: subtitleColor,
                                inputFillColor: inputFillColor,
                                inputBorderColor: inputBorderColor,
                                iconColor: iconColor,
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              controller: _passwordController,
                              enabled: !_isLoading,
                              obscureText: _isPasswordHidden,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: titleColor),
                              decoration: _inputDecoration(
                                label: 'Contraseña',
                                icon: Icons.lock_outline,
                                isDark: isDark,
                                subtitleColor: subtitleColor,
                                inputFillColor: inputFillColor,
                                inputBorderColor: inputBorderColor,
                                iconColor: iconColor,
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
                              ),
                            ),

                            const SizedBox(height: 28),

                            _buildSectionTitle('Perfil físico', titleColor),

                            const SizedBox(height: 12),

                            TextField(
                              controller: _ageController,
                              enabled: !_isLoading,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: titleColor),
                              decoration: _inputDecoration(
                                label: 'Edad',
                                icon: Icons.cake_outlined,
                                isDark: isDark,
                                subtitleColor: subtitleColor,
                                inputFillColor: inputFillColor,
                                inputBorderColor: inputBorderColor,
                                iconColor: iconColor,
                              ),
                            ),

                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              dropdownColor: cardColor,
                              style: TextStyle(color: titleColor),
                              decoration: _inputDecoration(
                                label: 'Género',
                                icon: Icons.person_outline_rounded,
                                isDark: isDark,
                                subtitleColor: subtitleColor,
                                inputFillColor: inputFillColor,
                                inputBorderColor: inputBorderColor,
                                iconColor: iconColor,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Masculino',
                                  child: Text('Masculino'),
                                ),
                                DropdownMenuItem(
                                  value: 'Femenino',
                                  child: Text('Femenino'),
                                ),
                                DropdownMenuItem(
                                  value: 'Otro',
                                  child: Text('Otro'),
                                ),
                              ],
                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val == null) return;
                                      setState(() => _selectedGender = val);
                                    },
                            ),

                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              initialValue: _selectedExperience,
                              dropdownColor: cardColor,
                              style: TextStyle(color: titleColor),
                              decoration: _inputDecoration(
                                label: 'Nivel de experiencia',
                                icon: Icons.trending_up_rounded,
                                isDark: isDark,
                                subtitleColor: subtitleColor,
                                inputFillColor: inputFillColor,
                                inputBorderColor: inputBorderColor,
                                iconColor: iconColor,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'principiante',
                                  child: Text('Principiante (0-6 meses)'),
                                ),
                                DropdownMenuItem(
                                  value: 'intermedio',
                                  child: Text('Intermedio (6m - 2 años)'),
                                ),
                                DropdownMenuItem(
                                  value: 'avanzado',
                                  child: Text('Avanzado (+2 años)'),
                                ),
                              ],
                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val == null) return;
                                      setState(() => _selectedExperience = val);
                                    },
                            ),

                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              initialValue: _selectedGoal,
                              dropdownColor: cardColor,
                              style: TextStyle(color: titleColor),
                              decoration: _inputDecoration(
                                label: 'Objetivo principal',
                                icon: Icons.flag_outlined,
                                isDark: isDark,
                                subtitleColor: subtitleColor,
                                inputFillColor: inputFillColor,
                                inputBorderColor: inputBorderColor,
                                iconColor: iconColor,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Salud y bienestar',
                                  child: Text('Salud y bienestar'),
                                ),
                                DropdownMenuItem(
                                  value: 'Pérdida de grasa',
                                  child: Text('Pérdida de grasa'),
                                ),
                                DropdownMenuItem(
                                  value: 'Aumento de masa muscular',
                                  child: Text('Aumento de masa muscular'),
                                ),
                                DropdownMenuItem(
                                  value: 'Rendimiento deportivo',
                                  child: Text('Rendimiento deportivo'),
                                ),
                              ],
                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val == null) return;
                                      setState(() => _selectedGoal = val);
                                    },
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _doRegister,
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
                                        'FINALIZAR REGISTRO',
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

  Widget _buildSectionTitle(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    required Color subtitleColor,
    required Color inputFillColor,
    required Color inputBorderColor,
    required Color iconColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: subtitleColor),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
