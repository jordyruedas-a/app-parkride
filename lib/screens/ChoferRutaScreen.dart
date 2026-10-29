import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/airport_route_service.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/campus_flutter_map.dart';

class ChoferRutaScreen extends StatefulWidget {
  const ChoferRutaScreen({super.key});

  @override
  State<ChoferRutaScreen> createState() => _ChoferRutaScreenState();
}

class _ChoferRutaScreenState extends State<ChoferRutaScreen> {
  final state = ParkRideState();
  int _selectedRouteIndex = 0;
  int _boardedCount = 14;
  int _currentStopIndex = 0;
  String _serviceStatus = "En Ruta";

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _advanceStop() {
    final route = AirportRouteService.fixedRoutes[_selectedRouteIndex];
    if (_currentStopIndex < route.stops.length - 1) {
      setState(() {
        _currentStopIndex++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Avanzando a parada: ${route.stops[_currentStopIndex].nombre}"),
          backgroundColor: const Color(0xFF22C55E),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Has llegado a la terminal final de la ruta."),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = AirportRouteService.fixedRoutes;
    final currentRoute = routes[_selectedRouteIndex];
    final currentStop = currentRoute.stops.isNotEmpty
        ? currentRoute
            .stops[_currentStopIndex.clamp(0, currentRoute.stops.length - 1)]
        : null;

    final LatLng routeCenter = currentRoute.stops.isNotEmpty
        ? LatLng(
            currentRoute.stops.map((s) => s.latitude).reduce((a, b) => a + b) /
                currentRoute.stops.length,
            currentRoute.stops.map((s) => s.longitude).reduce((a, b) => a + b) /
                currentRoute.stops.length,
          )
        : ParkRideState.campusCenter;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const AppLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Operador de Ruta Dedicada",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Unidad 08 • Autobús Corporativo Scania",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF22C55E)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
                const SizedBox(width: 6),
                Text(
                  _serviceStatus,
                  style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de ruta asignada
            Container(
              height: 48,
              color: const Color(0xFF1E293B),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: routes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedRouteIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRouteIndex = index;
                        _currentStopIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Ruta ${index + 1}: ${routes[index].routeName}",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Mapa de ruta
            Expanded(
              flex: 4,
              child: CampusFlutterMap(
                initialCenter: routeCenter,
                initialZoom: 12.0,
                selectedOrigen: currentRoute.stops.first,
                selectedDestino: currentRoute.stops.last,
                showDriverLocation: true,
                driverPosition: currentStop?.latLng ?? routeCenter,
              ),
            ),

            // Panel de Control de Ruta y Pasajeros
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Info de ruta y pasajeros
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentRoute.routeName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Frecuencia: ${currentRoute.schedule}",
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_alt_rounded,
                                color: Color(0xFF2563EB), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "$_boardedCount / 38",
                              style: const TextStyle(
                                color: Color(0xFF1E40AF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Próxima parada activa
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on,
                              color: Color(0xFF22C55E), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Parada Actual: ${currentStop?.nombre ?? 'Terminal'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Parada ${_currentStopIndex + 1} de ${currentRoute.stops.length} • Próxima: ${(_currentStopIndex + 1 < currentRoute.stops.length) ? currentRoute.stops[_currentStopIndex + 1].nombre : 'Fin de ruta'}",
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded,
                              color: Color(0xFF22C55E)),
                          tooltip: "Siguiente parada",
                          onPressed: _advanceStop,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón Principal: Escanear QR de Abordaje
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/CodigoQR');
                        if (mounted) {
                          setState(() {
                            _boardedCount++;
                          });
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                      label: const Text(
                        "Escanear QR de Abordaje",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
