import 'package:flutter/material.dart';
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
  late Future<Map<String, dynamic>> _analyticsFuture;
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
    _analyticsFuture = ApiService.getAdminAnalytics();
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

  void _refreshAnalytics() {
    setState(() {
      _analyticsFuture = ApiService.getAdminAnalytics();
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
            ? Colors.white.withOpacity(0.08)
            : Colors.transparent;
        final Color innerCardColor = isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF8FAFC);
        final Color innerBorderColor = isDark
            ? Colors.white.withOpacity(0.10)
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
                          _refreshAnalytics();
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
                          _buildSelectedSection(
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

  Widget _buildSelectedSection({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    if (selectedTab == 0) {
      return _buildUsersSection(
        isDark: isDark,
        cardColor: cardColor,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        borderColor: borderColor,
        innerCardColor: innerCardColor,
        innerBorderColor: innerBorderColor,
      );
    }

    if (selectedTab == 1) {
      return _buildExercisesSection(
        isDark: isDark,
        cardColor: cardColor,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        borderColor: borderColor,
        innerCardColor: innerCardColor,
        innerBorderColor: innerBorderColor,
      );
    }

    return _buildAnalyticsSection(
      isDark: isDark,
      cardColor: cardColor,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      borderColor: borderColor,
      innerCardColor: innerCardColor,
      innerBorderColor: innerBorderColor,
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
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = constraints.maxWidth < 360 ? 8.0 : 10.0;
              final width = (constraints.maxWidth - spacing * 2) / 3;

              return Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: width,
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
                  SizedBox(
                    width: width,
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
                  SizedBox(
                    width: width,
                    child: _buildTabButton(
                      label: 'Analitica',
                      icon: Icons.insights_rounded,
                      active: selectedTab == 2,
                      isDark: isDark,
                      innerCardColor: innerCardColor,
                      innerBorderColor: innerBorderColor,
                      onTap: () => setState(() => selectedTab = 2),
                    ),
                  ),
                ],
              );
            },
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : (isDark ? Colors.white : primaryColor),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
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
                  final workoutCount =
                      (user['workoutCount'] as num?)?.toInt() ?? 0;
                  final savedRoutineCount =
                      (user['savedRoutineCount'] as num?)?.toInt() ?? 0;
                  final name = username.isNotEmpty ? username : email;
                  return _buildUserItem(
                    userId: id,
                    name: name,
                    email: email,
                    role: role,
                    routineCount: workoutCount + savedRoutineCount,
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
                ? warningColor.withOpacity(isDark ? 0.22 : 0.15)
                : primaryColor.withOpacity(isDark ? 0.22 : 0.12),
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
                          color: warningColor.withOpacity(isDark ? 0.22 : 0.12),
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
                  '$routineCount rutinas',
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
              tooltip: 'Ver rutinas',
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
              color: warningColor.withOpacity(isDark ? 0.22 : 0.12),
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

  // ANALITICA

  Widget _buildAnalyticsSection({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return _AdminSectionCard(
      title: 'Analitica',
      subtitle: 'Actividad, RPE y estado previo de los usuarios',
      isDark: isDark,
      cardColor: cardColor,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
      borderColor: borderColor,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
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
              message: 'No se pudo cargar la analitica',
              detail: snapshot.error.toString(),
              onRetry: _refreshAnalytics,
            );
          }

          final data = snapshot.data ?? {};
          final totals = data['totals'] is Map
              ? Map<String, dynamic>.from(data['totals'])
              : <String, dynamic>{};
          final commonDays = _asMapList(data['commonExerciseDays']);
          final weeklyFrequency = _asMapList(data['weeklyDayFrequency']);
          final rpeFrequency = _asMapList(data['rpeFrequency']);
          final preWorkoutMood = _asMapList(data['preWorkoutMood']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAnalyticsSummaryGrid(
                totals: totals,
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsBlock(
                title: 'Dias mas comunes de ejercitacion',
                subtitle: 'Rutinas completadas por dia',
                icon: Icons.calendar_month_rounded,
                color: primaryColor,
                items: commonDays,
                emptyMessage: 'Aun no hay rutinas completadas.',
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
                emptyMessage: 'Aun no hay semanas con entrenamiento.',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
              const SizedBox(height: 14),
              _buildAnalyticsBlock(
                title: 'Frecuencia de RPE por rutina',
                subtitle: 'RPE registrado al finalizar rutinas',
                icon: Icons.speed_rounded,
                color: warningColor,
                items: rpeFrequency,
                emptyMessage: 'Aun no hay RPE registrado.',
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
              const SizedBox(height: 14),
              _buildAnalyticsBlock(
                title: 'Sentimientos antes de la rutina',
                subtitle: 'Estado de animo previo segun bienestar',
                icon: Icons.sentiment_satisfied_alt_rounded,
                color: const Color(0xFFEC4899),
                items: preWorkoutMood,
                emptyMessage: 'Aun no hay bienestar asociado a rutinas.',
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

  Widget _buildAnalyticsSummaryGrid({
    required Map<String, dynamic> totals,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    final metrics = [
      {
        'label': 'Usuarios',
        'value': _asInt(totals['totalUsers']).toString(),
        'icon': Icons.people_alt_rounded,
        'color': primaryColor,
      },
      {
        'label': 'Rutinas completas',
        'value': _asInt(totals['completedWorkoutSessions']).toString(),
        'icon': Icons.check_circle_rounded,
        'color': secondaryColor,
      },
      {
        'label': 'Dias/sem. prom.',
        'value': _formatDecimal(_asDouble(totals['averageDaysPerWeek'])),
        'icon': Icons.date_range_rounded,
        'color': warningColor,
      },
      {
        'label': 'RPE prom.',
        'value': _formatDecimal(_asDouble(totals['averageRpe'])),
        'icon': Icons.bolt_rounded,
        'color': dangerColor,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool singleColumn = constraints.maxWidth < 310;
        final bool fourColumns = constraints.maxWidth >= 680;
        final int columns = singleColumn
            ? 1
            : fourColumns
            ? 4
            : 2;
        final double spacing = 10;
        final double width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics.map((metric) {
            return SizedBox(
              width: width,
              child: _buildAnalyticsMetricTile(
                label: metric['label'] as String,
                value: metric['value'] as String,
                icon: metric['icon'] as IconData,
                color: metric['color'] as Color,
                isDark: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                innerCardColor: innerCardColor,
                innerBorderColor: innerBorderColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnalyticsMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: innerBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  void _showUserRoutines({required String userId, required String name}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = AppThemeController.themeMode.value == ThemeMode.dark;
        final titleColor = isDark ? Colors.white : darkText;
        final subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;

        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.78,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rutinas de $name',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: ApiService.getAdminUserRoutines(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'No se pudieron cargar las rutinas',
                          style: TextStyle(color: subtitleColor),
                        ),
                      );
                    }

                    final sessions = List<Map<String, dynamic>>.from(
                      snapshot.data?['sessions'] ?? [],
                    );
                    final saved = List<Map<String, dynamic>>.from(
                      snapshot.data?['savedRoutines'] ?? [],
                    );
                    final items = [
                      ...saved.map((item) => {...item, '_type': 'saved'}),
                      ...sessions.map((item) => {...item, '_type': 'session'}),
                    ];

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'Este usuario no tiene rutinas.',
                          style: TextStyle(color: subtitleColor),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final type = item['_type'].toString();
                        final exercises = List.from(item['exercises'] ?? []);
                        final label = type == 'saved'
                            ? (item['name'] ?? 'Rutina guardada').toString()
                            : (item['recommendationLabel'] ?? 'Sesión')
                                  .toString();

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            type == 'saved'
                                ? Icons.bookmark_rounded
                                : Icons.fitness_center_rounded,
                            color: warningColor,
                          ),
                          title: Text(
                            label,
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            '${exercises.length} ejercicios',
                            style: TextStyle(color: subtitleColor),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: dangerColor,
                            onPressed: () async {
                              final success =
                                  await ApiService.deleteAdminRoutine(
                                    routineId: item['_id'].toString(),
                                    type: type,
                                  );
                              if (!mounted) return;
                              Navigator.pop(sheetContext);
                              if (success) {
                                _refreshUsers();
                                _showUserRoutines(userId: userId, name: name);
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
            ? Colors.white.withOpacity(0.14)
            : const Color(0xFFCBD5E1);
        final Color handleColor = isDark
            ? Colors.white.withOpacity(0.18)
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
                  value: selectedMuscle,
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
                  value: selectedLevel,
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
