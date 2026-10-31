import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/parkride_state.dart';
import '../services/airport_route_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/campus_flutter_map.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard>
    with SingleTickerProviderStateMixin {
  final state = ParkRideState();
  late TabController _tabController;
  int _selectedRouteIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;
    final routes = AirportRouteService.fixedRoutes;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        elevation: 0,
        title: Row(
          children: [
            const AppLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Panel de Supervisor",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.nombre.split(' ').first,
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF94A3B8)),
            onPressed: () {
              state.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/ParkrideLogin', (r) => false);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF22C55E),
          labelColor: const Color(0xFF22C55E),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.map_rounded, size: 18), text: "Mapa de Rutas"),
            Tab(
                icon: Icon(Icons.directions_bus_rounded, size: 18),
                text: "Rutas"),
            Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 18),
                text: "Reportes"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMapTab(routes),
            _buildRoutesTab(routes),
            _buildReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab(List<AirportRoute> routes) {
    final selectedRoute = routes[_selectedRouteIndex];

    return Column(
      children: [
        // Route selector
        Container(
          height: 48,
          color: const Color(0xFF0F172A),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedRouteIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedRouteIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'R${index + 1}',
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Map
        Expanded(
          flex: 3,
          child: CampusFlutterMap(
            initialCenter: LatLng(
              selectedRoute.stops
                      .map((s) => s.latitude)
                      .reduce((a, b) => a + b) /
                  selectedRoute.stops.length,
              selectedRoute.stops
                      .map((s) => s.longitude)
                      .reduce((a, b) => a + b) /
                  selectedRoute.stops.length,
            ),
            initialZoom: 11.0,
            selectedOrigen: selectedRoute.stops.first,
            selectedDestino: selectedRoute.stops.last,
          ),
        ),

        // Route info panel
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedRoute.routeName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                selectedRoute.description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Color(0xFF22C55E)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Horarios: ${selectedRoute.schedule}",
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF374151)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: selectedRoute.stops
                    .map((stop) => Chip(
                          label: Text(
                            stop.nombre.split(' - ').first,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF1E293B)),
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutesTab(List<AirportRoute> routes) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.routeName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A)),
                          ),
                          Text(
                            route.description,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Color(0xFF22C55E)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        route.schedule,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 4),
                    Text(
                      "${route.stops.length} paradas",
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF374151)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Stops list
                ...route.stops.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stop = entry.value;
                  final isFirst = i == 0;
                  final isLast = i == route.stops.length - 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isFirst
                                ? const Color(0xFF3B82F6)
                                : isLast
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFirst || isLast
                                  ? Colors.transparent
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stop.nombre,
                            style: TextStyle(
                              fontSize: 11,
                              color: isFirst || isLast
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF64748B),
                              fontWeight: isFirst || isLast
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
        },
      ),
    );
  }

  Widget _buildReportsTab() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Métricas del Sistema",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),

            const Text(
              "Bandeja de incidencias",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: state.getReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text(
                    "No se pudieron cargar las incidencias.",
                    style: TextStyle(color: Color(0xFF64748B)),
                  );
                }
                final reports = snapshot.data ?? const [];
                if (reports.isEmpty) {
                  return const Text(
                    "No hay incidencias pendientes.",
                    style: TextStyle(color: Color(0xFF64748B)),
                  );
                }
                return Column(
                  children: reports.map((report) {
                    final resolved = report['status'] == 'resolved';
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  report['category']?.toString() ??
                                      'Incidencia',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (!resolved)
                                TextButton(
                                  onPressed: () async {
                                    await state
                                        .resolveReport(report['id'].toString());
                                    if (mounted) setState(() {});
                                  },
                                  child: const Text('Marcar resuelto'),
                                )
                              else
                                const Text(
                                  'Resuelto',
                                  style: TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            report['comment']?.toString() ?? '',
                            style: const TextStyle(color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard("Rutas Activas", "9", Icons.route_rounded,
                    const Color(0xFF22C55E)),
                _buildStatCard("Viajes Hoy", "${state.tripHistory.length}",
                    Icons.directions_car_rounded, const Color(0xFF3B82F6)),
                _buildStatCard(
                    "CO₂ Ahorrado",
                    "${state.totalCo2SavingsKg.toStringAsFixed(1)} kg",
                    Icons.eco_rounded,
                    const Color(0xFF10B981)),
                _buildStatCard("Usuarios", "—", Icons.people_rounded,
                    const Color(0xFFF59E0B)),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Estado del Sistema",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            _buildStatusItem("Servicio de Rutas", true),
            _buildStatusItem("Módulo QR", true),
            _buildStatusItem(
                "Sincronización en Tiempo Real", state.isDriverOnline),
            _buildStatusItem("Base de Datos", true),

            const SizedBox(height: 24),

            const Text(
              "Historial de Viajes",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            if (state.tripHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, color: Color(0xFF94A3B8), size: 40),
                      SizedBox(height: 8),
                      Text(
                        "No hay viajes registrados",
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Los viajes aparecerán aquí una vez que los usuarios soliciten traslados.",
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...state.tripHistory.take(10).map((trip) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.directions_car,
                              color: Color(0xFF22C55E), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${trip.origen} → ${trip.destino}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                trip.pasajeroNombre,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            trip.estado,
                            style: const TextStyle(
                                color: Color(0xFF22C55E),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF22C55E) : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B)),
            ),
          ),
          Text(
            isActive ? "Operativo" : "Inactivo",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF22C55E) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
