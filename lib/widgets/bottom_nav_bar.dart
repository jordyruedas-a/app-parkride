import 'package:flutter/material.dart';

class ParkRideBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<ParkRideNavItem>? items;

  const ParkRideBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.items,
  });

  static const List<ParkRideNavItem> driverItems = [
    ParkRideNavItem(
        icon: Icons.route_rounded, label: 'Mi Ruta', route: '/ChoferRuta'),
    ParkRideNavItem(
        icon: Icons.space_dashboard_rounded,
        label: 'Mis Viajes',
        route: '/ChoferDashboard'),
    ParkRideNavItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
        route: '/ParkrideProfileSettings'),
  ];

  static const List<ParkRideNavItem> _passengerItems = [
    ParkRideNavItem(
        icon: Icons.home_rounded, label: 'Inicio', route: '/ParkrideDashboard'),
    ParkRideNavItem(
        icon: Icons.directions_car_filled_rounded,
        label: 'Solicitar',
        route: '/SolicitarViaje'),
    ParkRideNavItem(
        icon: Icons.history_rounded,
        label: 'Mis Viajes',
        route: '/HistorialViajes'),
    ParkRideNavItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
        route: '/ParkrideProfileSettings'),
  ];

  @override
  Widget build(BuildContext context) {
    final resolvedItems = items ?? _passengerItems;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidgets = List.generate(resolvedItems.length, (index) {
                final item = resolvedItems[index];
                final selected = currentIndex == index;
                return InkWell(
                  onTap: () {
                    if (onTap != null) {
                      onTap!(index);
                    } else if (ModalRoute.of(context)?.settings.name !=
                        item.route) {
                      Navigator.pushNamed(context, item.route);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon,
                            color: selected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF64748B)),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
              return constraints.maxWidth < 360
                  ? Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 6,
                      children: itemWidgets)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: itemWidgets);
            },
          ),
        ),
      ),
    );
  }
}

class ParkRideNavItem {
  final IconData icon;
  final String label;
  final String route;

  const ParkRideNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
