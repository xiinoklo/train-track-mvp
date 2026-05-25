import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int selectedTab = 0;

  late Future<List<Map<String, dynamic>>> _usersFuture;
  late Future<List<Map<String, dynamic>>> _exercisesFuture;
  String _userSearch = '';

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
    _usersFuture = ApiService.getAdminUsers();
    _exercisesFuture = ApiService.getAdminExercises();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = ApiService.getAdminUsers();
    });
  }

  void _refreshExercises() {
    setState(() {
      _exercisesFuture = ApiService.getAdminExercises();
    });
  }

  Future<void> _logoutAdmin() async {
    await ApiService.adminLogout();
    if (!mounted) return;
    Navigator.pop(context);
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
        final Color borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.transparent;
        final Color innerCardColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
        final Color innerBorderColor = isDark ? Colors.white.withOpacity(0.10) : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: pageBackground,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF020617), Color(0xFF1E3A8A), Color(0xFF020617)]
                    : const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.30, 0.30],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  Expanded(
                    child: RefreshIndicator(
                      color: primaryColor,
                      onRefresh: () async {
                        if (selectedTab == 0) {
                          _refreshUsers();
                        } else {
                          _refreshExercises();
                        }
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          _buildMainCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            borderColor: borderColor,
                            innerCardColor: innerCardColor,
                            innerBorderColor: innerBorderColor,
                          ),
                          const SizedBox(height: 18),
                          selectedTab == 0
                              ? _buildUsersSection(
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                  innerCardColor: innerCardColor,
                                  innerBorderColor: innerBorderColor,
                                )
                              : _buildExercisesSection(
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                  innerCardColor: innerCardColor,
                                  innerBorderColor: innerBorderColor,
                                ),
                        ],
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

  Widget _buildHeader(bool isDark) {
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
              'Panel Admin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
          _buildThemeButton(isDark),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _logoutAdmin,
            icon: const Icon(Icons.logout_rounded),
            color: Colors.white,
            tooltip: 'Salir',
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
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
                  Icons.admin_panel_settings_rounded,
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
                      'Administración TrainTrack',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestiona usuarios, ejercicios y videos.',
                      style: TextStyle(
                        fontSize: 13,
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
                child: _buildTabButton(
                  label: 'Usuarios',
                  icon: Icons.people_alt_rounded,
                  active: selectedTab == 0,
                  isDark: isDark,
                  innerCardColor: innerCardColor,
                  innerBorderColor: innerBorderColor,
                  onTap: () => setState(() => selectedTab = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  label: 'Ejercicios',
                  icon: Icons.fitness_center_rounded,
                  active: selectedTab == 1,
                  isDark: isDark,
                  innerCardColor: innerCardColor,
                  innerBorderColor: innerBorderColor,
                  onTap: () => setState(() => selectedTab = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool active,
    required bool isDark,
    required Color innerCardColor,
    required Color innerBorderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? primaryColor : innerCardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: active ? primaryColor : innerBorderColor),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? Colors.white : (isDark ? Colors.white : primaryColor),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : (isDark ? Colors.white : primaryColor),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── USUARIOS ────────────────────────────────────────────────────────────────

  Widget _buildUsersSection({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return _AdminSectionCard(
      title: 'Usuarios',
      subtitle: 'Lista de usuarios registrados',
      isDark: isDark,
      cardColor: cardColor,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      borderColor: borderColor,
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: titleColor),
            onChanged: (value) => setState(() => _userSearch = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Buscar usuario...',
              hintStyle: TextStyle(color: subtitleColor),
              prefixIcon: Icon(Icons.search_rounded, color: subtitleColor),
              filled: true,
              fillColor: innerCardColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: innerBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: primaryColor, width: 1.6),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: primaryColor)),
                );
              }
              if (snapshot.hasError) {
                return _buildErrorBox(
                  isDark: isDark,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  message: 'No se pudieron cargar los usuarios',
                  detail: snapshot.error.toString(),
                  onRetry: _refreshUsers,
                );
              }
              final users = snapshot.data ?? [];
              final filtered = users.where((u) {
                if (_userSearch.isEmpty) return true;
                final email = (u['email'] ?? '').toString().toLowerCase();
                final username = (u['username'] ?? '').toString().toLowerCase();
                return email.contains(_userSearch) || username.contains(_userSearch);
              }).toList();

              if (filtered.isEmpty) {
                return _buildEmptyBox(innerCardColor, innerBorderColor, subtitleColor, 'No hay usuarios para mostrar.');
              }
              return Column(
                children: filtered.map((user) {
                  final id = (user['_id'] ?? user['id'] ?? '').toString();
                  final email = (user['email'] ?? 'Sin correo').toString();
                  final username = (user['username'] ?? '').toString();
                  final role = (user['role'] ?? 'user').toString();
                  final name = username.isNotEmpty ? username : email;
                  return _buildUserItem(
                    userId: id,
                    name: name,
                    email: email,
                    role: role,
                    isDark: isDark,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    innerCardColor: innerCardColor,
                    innerBorderColor: innerBorderColor,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem({
    required String userId,
    required String name,
    required String email,
    required String role,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    final bool isAdmin = role == 'admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: innerBorderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isAdmin
                ? warningColor.withOpacity(isDark ? 0.22 : 0.15)
                : primaryColor.withOpacity(isDark ? 0.22 : 0.12),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
              color: isAdmin ? warningColor : primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: titleColor, fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: warningColor.withOpacity(isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(color: warningColor, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isAdmin || userId.isEmpty
                ? null
                : () => _confirmDeleteUser(userId: userId, name: name),
            icon: const Icon(Icons.delete_outline_rounded),
            color: isAdmin ? Colors.grey : dangerColor,
            tooltip: isAdmin ? 'No puedes eliminar un admin' : 'Eliminar usuario',
          ),
        ],
      ),
    );
  }

  // ─── EJERCICIOS ──────────────────────────────────────────────────────────────

  Widget _buildExercisesSection({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return _AdminSectionCard(
      title: 'Ejercicios',
      subtitle: 'Agrega, edita o elimina ejercicios',
      isDark: isDark,
      cardColor: cardColor,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => _openExerciseForm(
              isDark: isDark,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('AGREGAR EJERCICIO', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _exercisesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: primaryColor)),
                );
              }
              if (snapshot.hasError) {
                return _buildErrorBox(
                  isDark: isDark,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  message: 'No se pudieron cargar los ejercicios',
                  detail: snapshot.error.toString(),
                  onRetry: _refreshExercises,
                );
              }
              final exercises = snapshot.data ?? [];
              if (exercises.isEmpty) {
                return _buildEmptyBox(innerCardColor, innerBorderColor, subtitleColor, 'No hay ejercicios. ¡Agrega el primero!');
              }
              return Column(
                children: exercises.map((exercise) {
                  final id = (exercise['_id'] ?? '').toString();
                  final name = (exercise['name'] ?? 'Sin nombre').toString();
                  final muscle = (exercise['muscleGroup'] ?? '').toString();
                  final videoUrl = (exercise['videoUrl'] ?? '').toString();
                  final hasVideo = videoUrl.isNotEmpty;
                  return _buildExerciseItem(
                    exerciseId: id,
                    name: name,
                    muscle: muscle,
                    hasVideo: hasVideo,
                    exerciseData: exercise,
                    isDark: isDark,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    innerCardColor: innerCardColor,
                    innerBorderColor: innerBorderColor,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem({
    required String exerciseId,
    required String name,
    required String muscle,
    required bool hasVideo,
    required Map<String, dynamic> exerciseData,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: innerBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: warningColor.withOpacity(isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: warningColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  '$muscle · ${hasVideo ? 'Con video' : 'Sin video'}',
                  style: TextStyle(
                    color: hasVideo ? secondaryColor : dangerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openExerciseForm(
              isDark: isDark,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              exerciseData: exerciseData,
            ),
            icon: const Icon(Icons.edit_rounded),
            color: isDark ? Colors.white : primaryColor,
            tooltip: 'Editar ejercicio',
          ),
          IconButton(
            onPressed: () => _confirmDeleteExercise(exerciseId: exerciseId, name: name),
            icon: const Icon(Icons.delete_outline_rounded),
            color: dangerColor,
            tooltip: 'Eliminar ejercicio',
          ),
        ],
      ),
    );
  }

  // ─── DIÁLOGOS ─────────────────────────────────────────────────────────────────

  void _confirmDeleteUser({required String userId, required String name}) {
    final parentContext = context;
    final bool isDark = AppThemeController.themeMode.value == ThemeMode.dark;
    final Color dialogColor = isDark ? darkCard : Colors.white;
    final Color titleColor = isDark ? Colors.white : darkText;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Eliminar usuario', style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
              content: Text(
                '¿Seguro que quieres eliminar a $name?\n\nTambién se eliminará su historial y datos asociados.',
                style: TextStyle(color: subtitleColor),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.white : primaryColor)),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final success = await ApiService.deleteAdminUser(userId);
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (success) {
                            _refreshUsers();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(content: Text('$name eliminado correctamente'), backgroundColor: secondaryColor),
                            );
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text('No se pudo eliminar el usuario'), backgroundColor: dangerColor),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: dangerColor, foregroundColor: Colors.white),
                  child: isDeleting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteExercise({required String exerciseId, required String name}) {
    final parentContext = context;
    final bool isDark = AppThemeController.themeMode.value == ThemeMode.dark;
    final Color dialogColor = isDark ? darkCard : Colors.white;
    final Color titleColor = isDark ? Colors.white : darkText;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Eliminar ejercicio', style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
              content: Text('¿Seguro que quieres eliminar "$name"?', style: TextStyle(color: subtitleColor)),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.white : primaryColor)),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final success = await ApiService.deleteAdminExercise(exerciseId);
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (success) {
                            _refreshExercises();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(content: Text('"$name" eliminado correctamente'), backgroundColor: secondaryColor),
                            );
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text('No se pudo eliminar el ejercicio'), backgroundColor: dangerColor),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: dangerColor, foregroundColor: Colors.white),
                  child: isDeleting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openExerciseForm({
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    Map<String, dynamic>? exerciseData,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _ExerciseFormSheet(exerciseData: exerciseData);
      },
    );

    if (!mounted) return;

    if (saved == true) {
      _refreshExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exerciseData == null ? 'Ejercicio agregado correctamente' : 'Ejercicio actualizado correctamente'),
          backgroundColor: secondaryColor,
        ),
      );
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────────

  Widget _buildErrorBox({
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required String message,
    required String detail,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dangerColor.withOpacity(isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dangerColor.withOpacity(isDark ? 0.35 : 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: dangerColor, size: 40),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(detail, textAlign: TextAlign.center, style: TextStyle(color: subtitleColor, fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(Color bg, Color border, Color textColor, String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildThemeButton(bool isDark) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
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

// ─── FORMULARIO DE EJERCICIO ──────────────────────────────────────────────────

class _ExerciseFormSheet extends StatefulWidget {
  final Map<String, dynamic>? exerciseData;

  const _ExerciseFormSheet({this.exerciseData});

  @override
  State<_ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<_ExerciseFormSheet> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController instructionsController;
  late final TextEditingController videoController;
  late String selectedMuscle;
  late String selectedLevel;
  bool _isSaving = false;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  bool get isEditing => widget.exerciseData != null;
  String get exerciseId => (widget.exerciseData?['_id'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    final d = widget.exerciseData;
    nameController = TextEditingController(text: d?['name'] ?? '');
    descriptionController = TextEditingController(text: d?['description'] ?? '');
    instructionsController = TextEditingController(text: d?['instructions'] ?? '');
    videoController = TextEditingController(text: d?['videoUrl'] ?? '');
    selectedMuscle = _normalizeMuscle(d?['muscleGroup']);
    selectedLevel = _normalizeLevel(d?['level']);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    instructionsController.dispose();
    videoController.dispose();
    super.dispose();
  }

  String _normalizeMuscle(String? value) {
    final v = (value ?? '').toLowerCase().trim();
    const valid = ['pecho', 'espalda', 'piernas', 'hombros', 'brazos', 'core'];
    return valid.contains(v) ? v : 'piernas';
  }

  String _normalizeLevel(String? value) {
    final v = (value ?? '').toLowerCase().trim();
    const valid = ['principiante', 'intermedio', 'avanzado'];
    return valid.contains(v) ? v : 'principiante';
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final instructions = instructionsController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del ejercicio'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool success;

    if (isEditing) {
      success = await ApiService.updateAdminExercise(
        exerciseId: exerciseId,
        updates: {
          'name': name,
          'muscleGroup': selectedMuscle,
          'level': selectedLevel,
          'description': description.isNotEmpty ? description : name,
          'instructions': instructions.isNotEmpty ? instructions : description.isNotEmpty ? description : 'Sin instrucciones',
          'videoUrl': videoController.text.trim(),
        },
      );
    } else {
      success = await ApiService.createAdminExercise(
        name: name,
        muscleGroup: selectedMuscle,
        level: selectedLevel,
        description: description.isNotEmpty ? description : name,
        instructions: instructions.isNotEmpty ? instructions : description.isNotEmpty ? description : 'Sin instrucciones',
        videoUrl: videoController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Error al actualizar el ejercicio' : 'Error al crear el ejercicio'),
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
        final Color sheetColor = isDark ? darkCard : Colors.white;
        final Color titleColor = isDark ? Colors.white : darkText;
        final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[600]!;
        final Color inputFillColor = isDark ? const Color(0xFF111827) : Colors.white;
        final Color inputBorderColor = isDark ? Colors.white.withOpacity(0.14) : const Color(0xFFCBD5E1);
        final Color handleColor = isDark ? Colors.white.withOpacity(0.18) : Colors.grey[300]!;

        return Container(
          padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isEditing ? 'Editar ejercicio' : 'Agregar ejercicio',
                  style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco('Nombre', isDark, subtitleColor, inputFillColor, inputBorderColor),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 3,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco('Descripción', isDark, subtitleColor, inputFillColor, inputBorderColor),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: instructionsController,
                  minLines: 2,
                  maxLines: 3,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco('Instrucciones', isDark, subtitleColor, inputFillColor, inputBorderColor),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedMuscle,
                  dropdownColor: sheetColor,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco('Grupo muscular', isDark, subtitleColor, inputFillColor, inputBorderColor),
                  items: const [
                    DropdownMenuItem(value: 'pecho', child: Text('Pecho')),
                    DropdownMenuItem(value: 'espalda', child: Text('Espalda')),
                    DropdownMenuItem(value: 'piernas', child: Text('Piernas')),
                    DropdownMenuItem(value: 'hombros', child: Text('Hombros')),
                    DropdownMenuItem(value: 'brazos', child: Text('Brazos')),
                    DropdownMenuItem(value: 'core', child: Text('Core')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => selectedMuscle = v); },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  dropdownColor: sheetColor,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco('Nivel', isDark, subtitleColor, inputFillColor, inputBorderColor),
                  items: const [
                    DropdownMenuItem(value: 'principiante', child: Text('Principiante')),
                    DropdownMenuItem(value: 'intermedio', child: Text('Intermedio')),
                    DropdownMenuItem(value: 'avanzado', child: Text('Avanzado')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => selectedLevel = v); },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: videoController,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco('URL video YouTube (opcional)', isDark, subtitleColor, inputFillColor, inputBorderColor),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'GUARDANDO...' : 'GUARDAR',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDeco(String label, bool isDark, Color subtitleColor, Color fillColor, Color borderColor, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: subtitleColor),
      hintStyle: TextStyle(color: subtitleColor.withOpacity(0.7)),
      filled: true,
      fillColor: fillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.7),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

// ─── CARD CONTENEDOR DE SECCIÓN ───────────────────────────────────────────────

class _AdminSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool isDark;
  final Color cardColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color borderColor;

  const _AdminSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.isDark,
    required this.cardColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
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
          Text(title, style: TextStyle(color: titleColor, fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}