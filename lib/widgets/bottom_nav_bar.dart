import 'package:flutter/material.dart';

class ParkRideBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const ParkRideBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Inicio', 'route': '/ParkrideDashboard'},
      {'icon': Icons.directions_car_filled_rounded, 'label': 'Solicitar', 'route': '/SolicitarViaje'},
      {'icon': Icons.history_rounded, 'label': 'Mis Viajes', 'route': '/HistorialViajes'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Reportes', 'route': '/ReportesESG'},
      {'icon': Icons.person_rounded, 'label': 'Perfil', 'route': '/ParkrideProfileSettings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              return InkWell(
                onTap: () {
                  if (onTap != null) {
                    onTap!(index);
                  } else {
                    final route = item['route'] as String;
                    if (ModalRoute.of(context)?.settings.name != route) {
                      Navigator.pushNamed(context, route);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
