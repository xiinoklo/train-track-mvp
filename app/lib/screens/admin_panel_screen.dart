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
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = ApiService.getAdminUsers();
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

        final Color pageBackground =
            isDark ? darkBackground : lightBackground;

        final Color cardColor = isDark ? darkCard : Colors.white;

        final Color titleColor = isDark ? Colors.white : darkText;

        final Color subtitleColor =
            isDark ? Colors.white70 : Colors.grey[600]!;

        final Color borderColor =
            isDark ? Colors.white.withOpacity(0.08) : Colors.transparent;

        final Color innerCardColor =
            isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

        final Color innerBorderColor =
            isDark ? Colors.white.withOpacity(0.10) : const Color(0xFFE2E8F0);

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
                  onTap: () {
                    setState(() {
                      selectedTab = 0;
                    });
                  },
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
                  onTap: () {
                    setState(() {
                      selectedTab = 1;
                    });
                  },
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
            border: Border.all(
              color: active ? primaryColor : innerBorderColor,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active
                    ? Colors.white
                    : isDark
                        ? Colors.white
                        : primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : primaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            onChanged: (value) {
              setState(() {
                _userSearch = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar usuario...',
              hintStyle: TextStyle(color: subtitleColor),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: subtitleColor,
              ),
              filled: true,
              fillColor: innerCardColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: innerBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 1.6,
                ),
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
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: dangerColor.withOpacity(isDark ? 0.16 : 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: dangerColor.withOpacity(isDark ? 0.35 : 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: dangerColor,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No se pudieron cargar los usuarios',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _refreshUsers,
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

              final users = snapshot.data ?? [];

              final filteredUsers = users.where((user) {
                final email = (user['email'] ?? '').toString().toLowerCase();
                final username =
                    (user['username'] ?? '').toString().toLowerCase();

                if (_userSearch.isEmpty) return true;

                return email.contains(_userSearch) ||
                    username.contains(_userSearch);
              }).toList();

              if (filteredUsers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: innerCardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: innerBorderColor),
                  ),
                  child: Text(
                    'No hay usuarios para mostrar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtitleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return Column(
                children: filteredUsers.map((user) {
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
        border: Border.all(
          color: innerBorderColor,
        ),
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
              ],
            ),
          ),
          IconButton(
            onPressed: isAdmin || userId.isEmpty
                ? null
                : () {
                    _confirmDeleteUser(
                      userId: userId,
                      name: name,
                    );
                  },
            icon: const Icon(Icons.delete_outline_rounded),
            color: isAdmin ? Colors.grey : dangerColor,
            tooltip: isAdmin
                ? 'No puedes eliminar un admin desde aquí'
                : 'Eliminar usuario',
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection({
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    final exercises = [
      {
        'name': 'Sentadilla goblet',
        'muscle': 'Piernas',
        'video': 'Con video',
      },
      {
        'name': 'Remo en polea baja',
        'muscle': 'Espalda',
        'video': 'Con video',
      },
      {
        'name': 'Press militar',
        'muscle': 'Hombros',
        'video': 'Sin video',
      },
    ];

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
            onPressed: () => _openExerciseForm(),
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
          ...exercises.map(
            (exercise) => _buildExerciseItem(
              name: exercise['name']!,
              muscle: exercise['muscle']!,
              video: exercise['video']!,
              isDark: isDark,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              innerCardColor: innerCardColor,
              innerBorderColor: innerBorderColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem({
    required String name,
    required String muscle,
    required String video,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color innerCardColor,
    required Color innerBorderColor,
  }) {
    final bool hasVideo = video == 'Con video';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: innerBorderColor,
        ),
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
                  '$muscle · $video',
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
            onPressed: () {
              _openExerciseForm(
                name: name,
                muscle: muscle,
              );
            },
            icon: const Icon(Icons.edit_rounded),
            color: isDark ? Colors.white : primaryColor,
            tooltip: 'Editar ejercicio',
          ),
          IconButton(
            onPressed: () {
              _confirmDeleteExercise(name);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            color: dangerColor,
            tooltip: 'Eliminar ejercicio',
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser({
    required String userId,
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
                          setDialogState(() {
                            isDeleting = true;
                          });

                          final success =
                              await ApiService.deleteAdminUser(userId);

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
                                content: Text(
                                  'No se pudo eliminar el usuario',
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

  void _confirmDeleteExercise(String name) {
    final parentContext = context;

    final bool isDark = AppThemeController.themeMode.value == ThemeMode.dark;
    final Color dialogColor = isDark ? darkCard : Colors.white;
    final Color titleColor = isDark ? Colors.white : darkText;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.grey[700]!;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? Colors.white : primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Future.delayed(const Duration(milliseconds: 120), () {
                  if (!mounted) return;

                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('$name eliminado en modo demo'),
                      backgroundColor: dangerColor,
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openExerciseForm({
    String? name,
    String? muscle,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _ExerciseFormSheet(
          name: name,
          muscle: muscle,
        );
      },
    );

    if (!mounted) return;

    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            name == null
                ? 'Ejercicio agregado en modo demo'
                : 'Ejercicio editado en modo demo',
          ),
          backgroundColor: secondaryColor,
        ),
      );
    }
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

class _ExerciseFormSheet extends StatefulWidget {
  final String? name;
  final String? muscle;

  const _ExerciseFormSheet({
    this.name,
    this.muscle,
  });

  @override
  State<_ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<_ExerciseFormSheet> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController repsController;
  late final TextEditingController videoController;

  late String selectedMuscle;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name ?? '');
    descriptionController = TextEditingController();
    repsController = TextEditingController();
    videoController = TextEditingController();

    selectedMuscle = _normalizeMuscleValue(widget.muscle);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    repsController.dispose();
    videoController.dispose();
    super.dispose();
  }

  String _normalizeMuscleValue(String? value) {
    final text = (value ?? 'piernas')
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    switch (text) {
      case 'pecho':
        return 'pecho';
      case 'espalda':
        return 'espalda';
      case 'piernas':
        return 'piernas';
      case 'hombros':
        return 'hombros';
      case 'brazos':
        return 'brazos';
      case 'core':
        return 'core';
      default:
        return 'piernas';
    }
  }

  void _save() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre del ejercicio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
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
        final Color inputFillColor =
            isDark ? const Color(0xFF111827) : Colors.white;
        final Color inputBorderColor =
            isDark ? Colors.white.withOpacity(0.14) : const Color(0xFFCBD5E1);
        final Color handleColor =
            isDark ? Colors.white.withOpacity(0.18) : Colors.grey[300]!;

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
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
                  widget.name == null ? 'Agregar ejercicio' : 'Editar ejercicio',
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
                  decoration: _inputDecoration(
                    label: 'Nombre',
                    isDark: isDark,
                    subtitleColor: subtitleColor,
                    inputFillColor: inputFillColor,
                    inputBorderColor: inputBorderColor,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 3,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDecoration(
                    label: 'Descripción',
                    isDark: isDark,
                    subtitleColor: subtitleColor,
                    inputFillColor: inputFillColor,
                    inputBorderColor: inputBorderColor,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: repsController,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDecoration(
                    label: 'Repeticiones',
                    hint: 'Ej: 10-12',
                    isDark: isDark,
                    subtitleColor: subtitleColor,
                    inputFillColor: inputFillColor,
                    inputBorderColor: inputBorderColor,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedMuscle,
                  dropdownColor: sheetColor,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDecoration(
                    label: 'Grupo muscular',
                    isDark: isDark,
                    subtitleColor: subtitleColor,
                    inputFillColor: inputFillColor,
                    inputBorderColor: inputBorderColor,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'pecho',
                      child: Text('Pecho'),
                    ),
                    DropdownMenuItem(
                      value: 'espalda',
                      child: Text('Espalda'),
                    ),
                    DropdownMenuItem(
                      value: 'piernas',
                      child: Text('Piernas'),
                    ),
                    DropdownMenuItem(
                      value: 'hombros',
                      child: Text('Hombros'),
                    ),
                    DropdownMenuItem(
                      value: 'brazos',
                      child: Text('Brazos'),
                    ),
                    DropdownMenuItem(
                      value: 'core',
                      child: Text('Core'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedMuscle = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: videoController,
                  style: TextStyle(color: titleColor),
                  decoration: _inputDecoration(
                    label: 'URL video YouTube',
                    isDark: isDark,
                    subtitleColor: subtitleColor,
                    inputFillColor: inputFillColor,
                    inputBorderColor: inputBorderColor,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'GUARDAR',
                    style: TextStyle(fontWeight: FontWeight.w900),
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

  InputDecoration _inputDecoration({
    required String label,
    required bool isDark,
    required Color subtitleColor,
    required Color inputFillColor,
    required Color inputBorderColor,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: subtitleColor),
      hintStyle: TextStyle(color: subtitleColor.withOpacity(0.7)),
      filled: true,
      fillColor: inputFillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.7,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

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
            style: TextStyle(
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}