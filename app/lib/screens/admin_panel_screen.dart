import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int selectedTab = 0;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.30, 0.30],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _buildMainCard(),
                    const SizedBox(height: 18),
                    selectedTab == 0
                        ? _buildUsersSection()
                        : _buildExercisesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 18),
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
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout_rounded),
            color: Colors.white,
            tooltip: 'Salir',
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: primaryColor,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administración TrainTrack',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Gestiona usuarios, ejercicios y videos.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? primaryColor : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? Colors.white : primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : primaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    final users = [
      {
        'name': 'Benjamín Gómez',
        'email': 'bgomezm@utem.cl',
      },
      {
        'name': 'María Soto',
        'email': 'maria.soto@email.com',
      },
      {
        'name': 'Juan Rojas',
        'email': 'juan.rojas@email.com',
      },
    ];

    return _AdminSectionCard(
      title: 'Usuarios',
      subtitle: 'Lista de usuarios registrados',
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar usuario...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...users.map(
            (user) => _buildUserItem(
              name: user['name']!,
              email: user['email']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem({
    required String name,
    required String email,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFDBEAFE),
            child: Icon(
              Icons.person_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _confirmDeleteUser(name);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            color: dangerColor,
            tooltip: 'Eliminar usuario',
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _openExerciseForm,
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
  }) {
    final bool hasVideo = video == 'Con video';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: warningColor.withOpacity(0.12),
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
                  style: const TextStyle(
                    color: darkText,
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
            color: primaryColor,
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

  void _confirmDeleteUser(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text(
            '¿Seguro que quieres eliminar a $name?\n\nTambién se eliminará su historial y datos asociados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name eliminado en modo demo'),
                    backgroundColor: dangerColor,
                  ),
                );
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

  void _confirmDeleteExercise(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar ejercicio'),
          content: Text('¿Seguro que quieres eliminar "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name eliminado en modo demo'),
                    backgroundColor: dangerColor,
                  ),
                );
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

  void _openExerciseForm({
    String? name,
    String? muscle,
  }) {
    final nameController = TextEditingController(text: name ?? '');
    final descriptionController = TextEditingController();
    final repsController = TextEditingController();
    final videoController = TextEditingController();

    String selectedMuscle = muscle ?? 'piernas';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
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
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      name == null ? 'Agregar ejercicio' : 'Editar ejercicio',
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: repsController,
                      decoration: InputDecoration(
                        labelText: 'Repeticiones',
                        hintText: 'Ej: 10-12',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: selectedMuscle,
                      decoration: InputDecoration(
                        labelText: 'Grupo muscular',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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

                        setModalState(() {
                          selectedMuscle = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: videoController,
                      decoration: InputDecoration(
                        labelText: 'URL video YouTube',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);

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
                      },
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
      },
    ).whenComplete(() {
      nameController.dispose();
      descriptionController.dispose();
      repsController.dispose();
      videoController.dispose();
    });
  }
}

class _AdminSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AdminSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkText = Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
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
            style: const TextStyle(
              color: darkText,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
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