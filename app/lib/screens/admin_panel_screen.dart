import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../theme/app_theme_controller.dart';
import '../utils/navigation_guard.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int selectedTab = 0;

  late Future<List<Map<String, dynamic>>> _usersFuture;
  late Future<List<Map<String, dynamic>>> _exercisesFuture;
  late Future<Map<String, dynamic>> _statsFuture;
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
    _statsFuture = ApiService.getAdminStats();
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

  void _refreshStats() {
    setState(() {
      _statsFuture = ApiService.getAdminStats();
    });
  }

  Future<void> _logoutAdmin() async {
    await ApiService.adminLogout();
    if (!mounted) return;
    popIfPossible(context);
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
        final Color borderColor = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent;
        final Color innerCardColor = isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF8FAFC);
        final Color innerBorderColor = isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0);

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
                        } else if (selectedTab == 1) {
                          _refreshExercises();
                        } else {
                          _refreshStats();
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
                              : selectedTab == 1
                              ? _buildExercisesSection(
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                  borderColor: borderColor,
                                  innerCardColor: innerCardColor,
                                  innerBorderColor: innerBorderColor,
                                )
                              : _buildStatsSection(
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
            onPressed: () => popIfPossible(context),
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
                letterSpacing: 0,
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
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
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
                  color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.1),
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
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildTabButton(
                  label: 'Datos',
                  icon: Icons.analytics_rounded,
                  active: selectedTab == 2,
                  isDark: isDark,
                  innerCardColor: innerCardColor,
                  innerBorderColor: innerBorderColor,
                  onTap: () => setState(() => selectedTab = 2),
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
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white : primaryColor),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : (isDark ? Colors.white : primaryColor),
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
            onChanged: (value) =>
                setState(() => _userSearch = value.trim().toLowerCase()),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
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
                return email.contains(_userSearch) ||
                    username.contains(_userSearch);
              }).toList();

              if (filtered.isEmpty) {
                return _buildEmptyBox(
                  innerCardColor,
                  innerBorderColor,
                  subtitleColor,
                  'No hay usuarios para mostrar.',
                );
              }
              return Column(
                children: filtered.map((user) {
                  final id = (user['_id'] ?? user['id'] ?? '').toString();
                  final email = (user['email'] ?? 'Sin correo').toString();
                  final username = (user['username'] ?? '').toString();
                  final role = (user['role'] ?? 'user').toString();
                  final savedRoutineCount =
                      (user['savedRoutineCount'] as num?)?.toInt() ?? 0;
                  final name = username.isNotEmpty ? username : email;
                  return _buildUserItem(
                    userId: id,
                    name: name,
                    email: email,
                    role: role,
                    routineCount: savedRoutineCount,
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
    required int routineCount,
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
                ? warningColor.withValues(alpha: isDark ? 0.22 : 0.15)
                : primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
            child: Icon(
              isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
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
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: warningColor.withValues(
                            alpha: isDark ? 0.22 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: warningColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
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
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$routineCount ${routineCount == 1 ? 'rutina creada' : 'rutinas creadas'}',
                  style: const TextStyle(
                    color: warningColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (!isAdmin)
            IconButton(
              onPressed: userId.isEmpty
                  ? null
                  : () => _showUserRoutines(userId: userId, name: name),
              icon: const Icon(Icons.list_alt_rounded),
              color: primaryColor,
              tooltip: 'Ver rutinas creadas',
            ),
          if (!isAdmin)
            IconButton(
              onPressed: userId.isEmpty
                  ? null
                  : () => _showUserData(userId: userId, name: name),
              icon: const Icon(Icons.analytics_rounded),
              color: secondaryColor,
              tooltip: 'Ver datos',
            ),
          IconButton(
            onPressed: isAdmin || userId.isEmpty
                ? null
                : () => _confirmDeleteUser(userId: userId, name: name),
            icon: const Icon(Icons.delete_outline_rounded),
            color: isAdmin ? Colors.grey : dangerColor,
            tooltip: isAdmin
                ? 'No puedes eliminar un admin'
                : 'Eliminar usuario',
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
            label: const Text(
              'AGREGAR EJERCICIO',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
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
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
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
                return _buildEmptyBox(
                  innerCardColor,
                  innerBorderColor,
                  subtitleColor,
                  'No hay ejercicios. ¡Agrega el primero!',
                );
              }
              return Column(
                children: exercises.map((exercise) {
                  final id = (exercise['_id'] ?? '').toString();
                  final name = (exercise['name'] ?? 'Sin nombre').toString();
                  final muscle = (exercise['muscleGroup'] ?? '').toString();
                  final videoUrl = (exercise['videoUrl'] ?? '').toString();
                  final hasVideo = videoUrl.isNotEmpty;
                  final xp = (exercise['xp'] as num?)?.toInt() ?? 10;
                  return _buildExerciseItem(
                    exerciseId: id,
                    name: name,
                    muscle: muscle,
                    hasVideo: hasVideo,
                    xp: xp,
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
    required int xp,
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
              color: warningColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: warningColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$muscle · $xp XP · ${hasVideo ? 'Con video' : 'Sin video'}',
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
            onPressed: () =>
                _confirmDeleteExercise(exerciseId: exerciseId, name: name),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Eliminar usuario',
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Text(
                '¿Seguro que quieres eliminar a $name?\n\nTambién se eliminará su historial y datos asociados.',
                style: TextStyle(color: subtitleColor),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final success = await ApiService.deleteAdminUser(
                            userId,
                          );
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (success) {
                            _refreshUsers();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text('$name eliminado correctamente'),
                                backgroundColor: secondaryColor,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo eliminar el usuario'),
                                backgroundColor: dangerColor,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteExercise({
    required String exerciseId,
    required String name,
  }) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Eliminar ejercicio',
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Text(
                '¿Seguro que quieres eliminar "$name"?',
                style: TextStyle(color: subtitleColor),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final success = await ApiService.deleteAdminExercise(
                            exerciseId,
                          );
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (success) {
                            _refreshExercises();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"$name" eliminado correctamente',
                                ),
                                backgroundColor: secondaryColor,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo eliminar el ejercicio',
                                ),
                                backgroundColor: dangerColor,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatShortDate(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '';

    final localDate = parsed.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  String _routineExerciseDetails(Map<String, dynamic> exercise) {
    final parts = <String>[];
    final sets = _asInt(exercise['sets']);
    final reps = (exercise['reps'] ?? '').toString().trim();
    final weight = (exercise['weight'] ?? '').toString().trim();
    final xp = _asInt(exercise['xp']);

    if (sets > 0) parts.add('$sets series');
    if (reps.isNotEmpty) parts.add('$reps reps');
    if (weight.isNotEmpty) {
      final numericWeight = double.tryParse(weight.replaceAll(',', '.'));
      parts.add(numericWeight == null ? weight : '$weight kg');
    }
    if (xp > 0) parts.add('$xp XP');

    return parts.join(' • ');
  }

  Widget _buildRoutineInfoPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesOverview({
    required int routineCount,
    required int exerciseCount,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? primaryColor.withValues(alpha: 0.18)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDBEAFE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.32 : 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bookmark_added_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutinas creadas',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$routineCount ${routineCount == 1 ? 'rutina' : 'rutinas'} con $exerciseCount ${exerciseCount == 1 ? 'ejercicio' : 'ejercicios'} en total',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineExerciseRow({
    required Map<String, dynamic> exercise,
    required int index,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final name = (exercise['name'] ?? 'Ejercicio sin nombre').toString();
    final muscleGroup = (exercise['muscleGroup'] ?? '').toString().trim();
    final details = _routineExerciseDetails(exercise);
    final subtitle = [
      if (muscleGroup.isNotEmpty) muscleGroup,
      if (details.isNotEmpty) details,
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: secondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedRoutineCard({
    required Map<String, dynamic> routine,
    required int index,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
    required VoidCallback onDelete,
  }) {
    final exercises = _asMapList(routine['exercises']);
    final routineName = (routine['name'] ?? 'Rutina creada').toString();
    final createdAt = _formatShortDate(routine['createdAt']);
    final totalXp = exercises.fold<int>(
      0,
      (sum, exercise) => sum + _asInt(exercise['xp']),
    );

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: innerBorderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
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
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: warningColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: warningColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routineName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      createdAt.isEmpty
                          ? 'Rutina guardada'
                          : 'Creada $createdAt',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: dangerColor,
                tooltip: 'Eliminar rutina',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoutineInfoPill(
                icon: Icons.fitness_center_rounded,
                label:
                    '${exercises.length} ${exercises.length == 1 ? 'ejercicio' : 'ejercicios'}',
                color: primaryColor,
                isDark: isDark,
              ),
              if (totalXp > 0)
                _buildRoutineInfoPill(
                  icon: Icons.auto_awesome_rounded,
                  label: '$totalXp XP',
                  color: secondaryColor,
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 6),
          Text(
            'Ejercicios de la rutina',
            style: TextStyle(
              color: titleColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Esta rutina no tiene ejercicios registrados.',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            )
          else
            ...exercises.asMap().entries.map((entry) {
              return _buildRoutineExerciseRow(
                exercise: entry.value,
                index: entry.key,
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCreatedRoutinesEmptyState({
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: warningColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No hay rutinas creadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cuando el usuario guarde una rutina, aparecerá aquí con sus ejercicios.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserRoutines({required String userId, required String name}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = AppThemeController.themeMode.value == ThemeMode.dark;
        final dialogColor = isDark ? darkCard : Colors.white;
        final titleColor = isDark ? Colors.white : darkText;
        final subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;
        final innerCardColor = isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF8FAFC);
        final innerBorderColor = isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0);

        return AlertDialog(
          backgroundColor: dialogColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.bookmark_added_rounded, color: warningColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rutinas creadas de $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.68,
            ),
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.82,
              child: FutureBuilder<Map<String, dynamic>>(
                future: ApiService.getAdminUserRoutines(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'No se pudieron cargar las rutinas creadas',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: subtitleColor),
                        ),
                      ),
                    );
                  }

                  final saved = _asMapList(snapshot.data?['savedRoutines']);
                  final totalExercises = saved.fold<int>(0, (sum, item) {
                    return sum + _asMapList(item['exercises']).length;
                  });

                  if (saved.isEmpty) {
                    return SizedBox(
                      height: 260,
                      child: _buildCreatedRoutinesEmptyState(
                        isDark: isDark,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRoutinesOverview(
                          routineCount: saved.length,
                          exerciseCount: totalExercises,
                          isDark: isDark,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                        ),
                        const SizedBox(height: 12),
                        ...saved.asMap().entries.map((entry) {
                          final item = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == saved.length - 1 ? 0 : 12,
                            ),
                            child: _buildCreatedRoutineCard(
                              routine: item,
                              index: entry.key,
                              isDark: isDark,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                              innerCardColor: innerCardColor,
                              innerBorderColor: innerBorderColor,
                              onDelete: () async {
                                final navigator = Navigator.of(dialogContext);
                                final messenger = ScaffoldMessenger.of(context);
                                final success =
                                    await ApiService.deleteAdminRoutine(
                                      routineId: item['_id'].toString(),
                                      type: 'saved',
                                    );
                                if (!mounted) return;
                                navigator.pop();
                                if (success) {
                                  _refreshUsers();
                                  _showUserRoutines(userId: userId, name: name);
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No se pudo eliminar la rutina',
                                      ),
                                      backgroundColor: dangerColor,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
          content: Text(
            exerciseData == null
                ? 'Ejercicio agregado correctamente'
                : 'Ejercicio actualizado correctamente',
          ),
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
        color: dangerColor.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dangerColor.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: dangerColor, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: TextStyle(color: subtitleColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(
    Color bg,
    Color border,
    Color textColor,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
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

  // ─── ESTADÍSTICAS GLOBALES ───────────────────────────────────────────────────

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDecimal(double value) {
    final rounded = (value * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    }

    return rounded.toStringAsFixed(1);
  }

  Widget _buildAnalyticsBlock({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> items,
    required String emptyMessage,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    final int maxCount = items.fold<int>(0, (max, item) {
      final count = _asInt(item['count']);
      return count > max ? count : max;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: innerBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (maxCount == 0)
            Text(
              emptyMessage,
              style: TextStyle(
                color: subtitleColor,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Column(
              children: items.map((item) {
                return _buildAnalyticsBar(
                  label: (item['label'] ?? '').toString(),
                  count: _asInt(item['count']),
                  percentage: _asDouble(item['percentage']),
                  maxCount: maxCount,
                  color: color,
                  isDark: isDark,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsBar({
    required String label,
    required int count,
    required double percentage,
    required int maxCount,
    required Color color,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final progress = maxCount == 0 ? 0.0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: titleColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: progress.clamp(0.0, 1.0).toDouble(),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              '$count | ${_formatDecimal(percentage)}%',
              maxLines: 1,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTopExercisesTable({
    required List<Map<String, dynamic>> exercises,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: innerBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTableHeaderCell('#', width: 34, color: subtitleColor),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTableHeaderCell('Ejercicio', color: subtitleColor),
              ),
              const SizedBox(width: 8),
              _buildTableHeaderCell('Veces', width: 56, color: subtitleColor),
            ],
          ),
          const SizedBox(height: 8),
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No hay historial de ejercicios',
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
            )
          else
            ...exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              final rowColor = isDark
                  ? Colors.white.withValues(alpha: index.isEven ? 0.04 : 0.02)
                  : (index.isEven ? Colors.white : const Color(0xFFF1F5F9));

              return Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  color: rowColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: warningColor.withValues(
                          alpha: isDark ? 0.24 : 0.16,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: warningColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (exercise['name'] ?? 'Desconocido').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 54,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(
                          alpha: isDark ? 0.28 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_asInt(exercise['count'])}x',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildUserMetricTable({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> items,
    required String emptyMessage,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    final rows = items.where((item) => _asInt(item['count']) > 0).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: innerBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTableHeaderCell('Detalle', color: subtitleColor),
              ),
              const SizedBox(width: 8),
              _buildTableHeaderCell('N', width: 40, color: subtitleColor),
              const SizedBox(width: 8),
              _buildTableHeaderCell('%', width: 48, color: subtitleColor),
            ],
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                emptyMessage,
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
            )
          else
            ...rows.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (item['label'] ?? '').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTableValueCell(
                      _asInt(item['count']).toString(),
                      width: 40,
                      color: color,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildTableValueCell(
                      '${_formatDecimal(_asDouble(item['percentage']))}%',
                      width: 48,
                      color: color,
                      isDark: isDark,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(
    String text, {
    double? width,
    required Color color,
  }) {
    final child = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );

    if (width == null) return child;
    return SizedBox(width: width, child: child);
  }

  Widget _buildTableValueCell(
    String text, {
    required double width,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildStatsSection({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return _AdminSectionCard(
      title: 'Datos Generales',
      subtitle: 'Métricas clave de la plataforma',
      isDark: isDark,
      cardColor: cardColor,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      borderColor: borderColor,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorBox(
              isDark: isDark,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              message: 'No se pudieron cargar las estadísticas',
              detail: snapshot.error.toString(),
              onRetry: _refreshStats,
            );
          }
          final stats = snapshot.data!;
          final totalUsers = stats['totalUsers'] ?? 0;
          final usersPerRank = List<Map<String, dynamic>>.from(
            stats['usersPerRank'] ?? [],
          );
          final topExercises = List<Map<String, dynamic>>.from(
            stats['topExercises'] ?? [],
          );
          final commonDays = _asMapList(stats['commonExerciseDays']);
          final weeklyFrequency = _asMapList(stats['weeklyDayFrequency']);
          final rpeFrequency = _asMapList(stats['rpeFrequency']);
          final preWorkoutMood = _asMapList(stats['preWorkoutMood']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total Usuarios Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: innerCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: innerBorderColor),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.group_rounded,
                      color: primaryColor,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total de usuarios',
                      style: TextStyle(
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalUsers',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // PieChart Usuarios por Nivel
              Text(
                'Usuarios por Nivel',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              if (usersPerRank.isEmpty)
                Text(
                  'No hay datos de nivel',
                  style: TextStyle(color: subtitleColor),
                )
              else
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: usersPerRank.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final color = [
                          primaryColor,
                          secondaryColor,
                          warningColor,
                          dangerColor,
                          Colors.purple,
                        ][idx % 5];
                        return PieChartSectionData(
                          value: (item['count'] as num).toDouble(),
                          title: 'Lvl ${item['_id']}\n(${item['count']})',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          color: color,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Top Exercises
              Text(
                'Top 5 Ejercicios',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              if (topExercises.isEmpty)
                Text(
                  'No hay datos de ejercicios',
                  style: TextStyle(color: subtitleColor),
                )
              else
                ...topExercises.map((ex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: innerCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: innerBorderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ex['name'] ?? 'Desconocido',
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${ex['count']} veces',
                            style: const TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
              _buildAnalyticsBlock(
                title: 'Dias mas comunes de ejercitacion',
                subtitle: 'Dias mas comunes segun rutinas completadas',
                icon: Icons.calendar_month_rounded,
                color: primaryColor,
                items: commonDays,
                emptyMessage: 'No hay rutinas completadas.',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
              const SizedBox(height: 14),
              _buildAnalyticsBlock(
                title: 'Frecuencia de dias por semana',
                subtitle: 'Semanas agrupadas por dias entrenados',
                icon: Icons.view_week_rounded,
                color: secondaryColor,
                items: weeklyFrequency,
                emptyMessage: 'No hay semanas con entrenamiento.',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
              const SizedBox(height: 14),
              _buildAnalyticsBlock(
                title: 'Frecuencia de RPE por rutina',
                subtitle: 'RPE registrado al finalizar cada rutina',
                icon: Icons.speed_rounded,
                color: warningColor,
                items: rpeFrequency,
                emptyMessage: 'No hay RPE registrado.',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
              const SizedBox(height: 14),
              _buildAnalyticsBlock(
                title: 'Sentimientos antes de la rutina',
                subtitle: 'Plano general del animo previo registrado',
                icon: Icons.sentiment_satisfied_alt_rounded,
                color: const Color(0xFFEC4899),
                items: preWorkoutMood,
                emptyMessage: 'No hay bienestar asociado a rutinas.',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── ESTADÍSTICAS POR USUARIO ───────────────────────────────────────────────

  void _showUserData({required String userId, required String name}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final bool isDark =
            AppThemeController.themeMode.value == ThemeMode.dark;
        final Color dialogColor = isDark ? darkCard : Colors.white;
        final Color titleColor = isDark ? Colors.white : darkText;
        final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;
        final Color innerCardColor = isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF8FAFC);
        final Color innerBorderColor = isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0);

        return AlertDialog(
          backgroundColor: dialogColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.analytics_rounded, color: secondaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Datos de $name',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.68,
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: ApiService.getAdminUserStats(userId),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: secondaryColor),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Error al cargar datos',
                    style: TextStyle(color: dangerColor),
                  );
                }
                final data = snapshot.data!;
                final level = data['level'] ?? 1;
                final xp = data['xp'] ?? 0;
                final topExercises = List<Map<String, dynamic>>.from(
                  data['topExercises'] ?? [],
                );
                final commonDays = _asMapList(data['commonExerciseDays']);
                final weeklyFrequency = _asMapList(data['weeklyDayFrequency']);
                final rpeFrequency = _asMapList(data['rpeFrequency']);
                final preWorkoutMood = _asMapList(data['preWorkoutMood']);

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStatCard(
                              'Nivel',
                              '$level',
                              isDark,
                              warningColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniStatCard(
                              'XP Total',
                              '$xp',
                              isDark,
                              primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ejercicios más repetidos',
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildUserTopExercisesTable(
                        exercises: topExercises,
                        isDark: isDark,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        innerCardColor: innerCardColor,
                        innerBorderColor: innerBorderColor,
                      ),
                      const SizedBox(height: 18),
                      _buildUserMetricTable(
                        title: 'Dias mas comunes de ejercitacion',
                        subtitle: 'Dias mas comunes del usuario',
                        icon: Icons.calendar_month_rounded,
                        color: primaryColor,
                        items: commonDays,
                        emptyMessage: 'No hay rutinas completadas.',
                        isDark: isDark,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        innerCardColor: innerCardColor,
                        innerBorderColor: innerBorderColor,
                      ),
                      const SizedBox(height: 12),
                      _buildUserMetricTable(
                        title: 'Frecuencia de dias por semana',
                        subtitle: 'Semanas agrupadas por dias entrenados',
                        icon: Icons.view_week_rounded,
                        color: secondaryColor,
                        items: weeklyFrequency,
                        emptyMessage: 'No hay semanas con entrenamiento.',
                        isDark: isDark,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        innerCardColor: innerCardColor,
                        innerBorderColor: innerBorderColor,
                      ),
                      const SizedBox(height: 12),
                      _buildUserMetricTable(
                        title: 'Frecuencia de RPE por rutina',
                        subtitle: 'RPE registrado al finalizar cada rutina',
                        icon: Icons.speed_rounded,
                        color: warningColor,
                        items: rpeFrequency,
                        emptyMessage: 'No hay RPE registrado.',
                        isDark: isDark,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        innerCardColor: innerCardColor,
                        innerBorderColor: innerBorderColor,
                      ),
                      const SizedBox(height: 12),
                      _buildUserMetricTable(
                        title: 'Sentimientos antes de la rutina',
                        subtitle: 'Plano general del animo previo registrado',
                        icon: Icons.sentiment_satisfied_alt_rounded,
                        color: const Color(0xFFEC4899),
                        items: preWorkoutMood,
                        emptyMessage: 'No hay bienestar asociado a rutinas.',
                        isDark: isDark,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        innerCardColor: innerCardColor,
                        innerBorderColor: innerBorderColor,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cerrar', style: TextStyle(color: titleColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String value,
    bool isDark,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
  late final TextEditingController xpController;
  late String selectedMuscle;
  late String selectedLevel;
  bool _isSaving = false;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  bool get isEditing => widget.exerciseData != null;
  String get exerciseId => (widget.exerciseData?['_id'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    final d = widget.exerciseData;
    nameController = TextEditingController(text: d?['name'] ?? '');
    descriptionController = TextEditingController(
      text: d?['description'] ?? '',
    );
    instructionsController = TextEditingController(
      text: d?['instructions'] ?? '',
    );
    videoController = TextEditingController(text: d?['videoUrl'] ?? '');
    xpController = TextEditingController(text: '${d?['xp'] ?? 10}');
    selectedMuscle = _normalizeMuscle(d?['muscleGroup']);
    selectedLevel = _normalizeLevel(d?['level']);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    instructionsController.dispose();
    videoController.dispose();
    xpController.dispose();
    super.dispose();
  }

  String _normalizeMuscle(String? value) {
    final v = (value ?? '').toLowerCase().trim();
    const valid = [
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
    final xp = (int.tryParse(xpController.text.trim()) ?? 10).clamp(0, 100);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre del ejercicio'),
          backgroundColor: Colors.red,
        ),
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
          'instructions': instructions.isNotEmpty
              ? instructions
              : description.isNotEmpty
              ? description
              : 'Sin instrucciones',
          'videoUrl': videoController.text.trim(),
          'xp': xp,
        },
      );
    } else {
      success = await ApiService.createAdminExercise(
        name: name,
        muscleGroup: selectedMuscle,
        level: selectedLevel,
        description: description.isNotEmpty ? description : name,
        instructions: instructions.isNotEmpty
            ? instructions
            : description.isNotEmpty
            ? description
            : 'Sin instrucciones',
        videoUrl: videoController.text.trim(),
        xp: xp,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Error al actualizar el ejercicio'
                : 'Error al crear el ejercicio',
          ),
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
        final Color inputFillColor = isDark
            ? const Color(0xFF111827)
            : Colors.white;
        final Color inputBorderColor = isDark
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(0xFFCBD5E1);
        final Color handleColor = isDark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.grey[300]!;

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isEditing ? 'Editar ejercicio' : 'Agregar ejercicio',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco(
                    'Nombre',
                    isDark,
                    subtitleColor,
                    inputFillColor,
                    inputBorderColor,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: xpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration:
                      _inputDeco(
                        'XP del ejercicio',
                        isDark,
                        subtitleColor,
                        inputFillColor,
                        inputBorderColor,
                        hint: 'Ej: 10',
                      ).copyWith(
                        prefixIcon: const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFF59E0B),
                        ),
                        suffixText: 'XP',
                        helperText:
                            'Puntos otorgados al completar este ejercicio (0 a 100).',
                        helperMaxLines: 2,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 3,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco(
                    'Descripción',
                    isDark,
                    subtitleColor,
                    inputFillColor,
                    inputBorderColor,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: instructionsController,
                  minLines: 2,
                  maxLines: 3,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco(
                    'Instrucciones',
                    isDark,
                    subtitleColor,
                    inputFillColor,
                    inputBorderColor,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedMuscle,
                  dropdownColor: sheetColor,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco(
                    'Grupo muscular',
                    isDark,
                    subtitleColor,
                    inputFillColor,
                    inputBorderColor,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pecho', child: Text('Pecho')),
                    DropdownMenuItem(value: 'espalda', child: Text('Espalda')),
                    DropdownMenuItem(value: 'piernas', child: Text('Piernas')),
                    DropdownMenuItem(value: 'hombros', child: Text('Hombros')),
                    DropdownMenuItem(value: 'brazos', child: Text('Brazos')),
                    DropdownMenuItem(value: 'core', child: Text('Core')),
                    DropdownMenuItem(value: 'biceps', child: Text('Biceps')),
                    DropdownMenuItem(value: 'triceps', child: Text('Triceps')),
                    DropdownMenuItem(value: 'gluteos', child: Text('Gluteos')),
                    DropdownMenuItem(
                      value: 'cuadriceps',
                      child: Text('Cuadriceps'),
                    ),
                    DropdownMenuItem(value: 'isquios', child: Text('Isquios')),
                    DropdownMenuItem(
                      value: 'femorales',
                      child: Text('Femorales'),
                    ),
                    DropdownMenuItem(
                      value: 'pantorrillas',
                      child: Text('Pantorrillas'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => selectedMuscle = v);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  dropdownColor: sheetColor,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco(
                    'Nivel',
                    isDark,
                    subtitleColor,
                    inputFillColor,
                    inputBorderColor,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'principiante',
                      child: Text('Principiante'),
                    ),
                    DropdownMenuItem(
                      value: 'intermedio',
                      child: Text('Intermedio'),
                    ),
                    DropdownMenuItem(
                      value: 'avanzado',
                      child: Text('Avanzado'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => selectedLevel = v);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: videoController,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDeco(
                    'URL video YouTube (opcional)',
                    isDark,
                    subtitleColor,
                    inputFillColor,
                    inputBorderColor,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'GUARDANDO...' : 'GUARDAR',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDeco(
    String label,
    bool isDark,
    Color subtitleColor,
    Color fillColor,
    Color borderColor, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: subtitleColor),
      hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.7)),
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
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
