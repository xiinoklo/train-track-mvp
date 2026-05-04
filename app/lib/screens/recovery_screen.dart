import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> recoveryFuture;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    recoveryFuture = ApiService.getRecoveryStatus();

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

  Future<void> _refreshRecovery() async {
    setState(() {
      recoveryFuture = ApiService.getRecoveryStatus();
    });
  }

  Color _getStatusColor(String status, int remainingHours) {
    if (status == 'ready' || remainingHours == 0) {
      return secondaryColor;
    }

    if (remainingHours <= 24) {
      return warningColor;
    }

    return dangerColor;
  }

  IconData _getMuscleIcon(String muscleGroup) {
    switch (muscleGroup) {
      case 'pecho':
        return Icons.accessibility_new_rounded;
      case 'espalda':
        return Icons.airline_seat_flat_rounded;
      case 'piernas':
        return Icons.directions_run_rounded;
      case 'hombros':
        return Icons.fitness_center_rounded;
      case 'brazos':
        return Icons.sports_mma_rounded;
      case 'core':
        return Icons.self_improvement_rounded;
      default:
        return Icons.monitor_heart_rounded;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Sin entrenamientos recientes';

    try {
      final date = DateTime.parse(rawDate.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year · $hour:$minute';
    } catch (_) {
      return rawDate.toString();
    }
  }

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
            stops: [0.0, 0.34, 0.34],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: recoveryFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        }

                        final data = snapshot.data;
                        final List recovery = data?['recovery'] ?? [];

                        if (recovery.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: _refreshRecovery,
                          color: primaryColor,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            children: [
                              _buildSummaryCard(recovery),
                              const SizedBox(height: 18),
                              ...recovery.map(
                                (item) => _buildRecoveryCard(item),
                              ),
                            ],
                          ),
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
  }

  Widget _buildHeader(BuildContext context) {
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
              'Descanso Muscular',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List recovery) {
    final int readyCount = recovery.where((item) {
      final int remainingHours = item['remainingHours'] ?? 0;
      final String status = item['status'] ?? '';
      return status == 'ready' || remainingHours == 0;
    }).length;

    final int restCount = recovery.length - readyCount;

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: secondaryColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de recuperación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$readyCount grupos listos · $restCount en descanso',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCard(dynamic item) {
    final String muscleGroup = item['muscleGroup'] ?? 'grupo';
    final String status = item['status'] ?? 'ready';
    final String message = item['message'] ?? '';
    final int remainingHours = item['remainingHours'] ?? 0;
    final dynamic lastTrainedAt = item['lastTrainedAt'];
    final dynamic lastRpe = item['lastRpe'];

    final Color statusColor = _getStatusColor(status, remainingHours);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: statusColor.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _getMuscleIcon(muscleGroup),
              color: statusColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(muscleGroup),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Último entrenamiento: ${_formatDate(lastTrainedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (lastRpe != null)
                  Text(
                    'Último RPE: $lastRpe',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: remainingHours == 0
                ? Icon(
                    Icons.check_rounded,
                    color: statusColor,
                    size: 26,
                  )
                : Text(
                    '${remainingHours}h',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                size: 56,
                color: primaryColor,
              ),
              SizedBox(height: 18),
              Text(
                'Sin datos de recuperación',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Cuando finalices entrenamientos y registres RPE, aparecerá aquí tu descanso muscular.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: dangerColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: dangerColor,
              ),
              const SizedBox(height: 18),
              const Text(
                'Error al cargar recuperación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _refreshRecovery,
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
}