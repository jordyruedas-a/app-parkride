import 'package:flutter/material.dart';

import '../services/parkride_state.dart';
import '../widgets/bottom_nav_bar.dart';

class ChoferDashboard extends StatelessWidget {
  const ChoferDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParkRideState();
    final completedToday = state.tripHistory
        .where((trip) =>
            trip.timestamp.year == DateTime.now().year &&
            trip.timestamp.month == DateTime.now().month &&
            trip.timestamp.day == DateTime.now().day)
        .length;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dashboard de Ruta'),
        actions: [
          IconButton(
            tooltip: 'Mi ruta',
            icon: const Icon(Icons.route_rounded),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/ChoferRuta'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${state.currentUser.nombre}',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Resumen operativo de hoy',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    label: 'Viajes completados',
                    value: '$completedToday',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF22C55E),
                  ),
                  _MetricCard(
                    label: 'Usuarios transportados',
                    value: '${completedToday * 14}',
                    icon: Icons.people_alt_outlined,
                    color: const Color(0xFF2563EB),
                  ),
                  const _MetricCard(
                    label: 'Horas de servicio',
                    value: '0.0 h',
                    icon: Icons.schedule_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado de la unidad',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.driverStatus,
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(
        currentIndex: 1,
        items: ParkRideBottomNavBar.driverItems,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
