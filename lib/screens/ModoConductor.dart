import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/parkride_models.dart';
import '../services/location_service.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/campus_flutter_map.dart';

class ModoConductor extends StatefulWidget {
  const ModoConductor({super.key});

  @override
  State<ModoConductor> createState() => _ModoConductorState();
}

class _ModoConductorState extends State<ModoConductor> {
  final state = ParkRideState();
  late LatLng _mapCenter;
  List<String> _selectedAvenues = [
    'Av. Gonzalitos',
    'Av. Morones Prieto',
  ];

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
    _mapCenter = state.userCurrentLocation;
    _refreshCurrentLocation();
  }

  Future<void> _refreshCurrentLocation() async {
    final position = await ParkRideLocationService().getCurrentPosition();
    if (!mounted || position == null) {
      return;
    }
    setState(() {
      state.userCurrentLocation = position;
      _mapCenter = position;
    });
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _setDriverState(String newStatus) {
    setState(() {
      state.driverStatus = newStatus;
      if (newStatus == 'Desconectado') {
        state.isDriverOnline = false;
      } else {
        state.isDriverOnline = true;
      }
    });
  }

  Future<void> _promptForAvenues() async {
    final commonAvenues = [
      'Av. Gonzalitos',
      'Av. Morones Prieto',
      'Av. Constitución',
      'Av. Universidad',
      'Av. Manuel L. Barragán',
      'Av. Miguel Alemán',
      'Carretera a Laredo',
      'Av. Paseo de los Leones',
      'Av. Eloy Cavazos',
      'Av. Cuauhtémoc (Santa Catarina)',
    ];

    List<String> tempSelected = List.from(_selectedAvenues);
    final customController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Icon(Icons.alt_route_rounded,
                              color: Color(0xFF22C55E), size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Avenidas de tu Trayecto",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Indica las principales avenidas por las que circularás para conectar con compañeros compatibles con tu trayecto.",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: commonAvenues.map((ave) {
                          final isSelected = tempSelected.contains(ave);
                          return FilterChip(
                            label: Text(ave),
                            selected: isSelected,
                            selectedColor:
                                const Color(0xFF22C55E).withValues(alpha: 0.2),
                            checkmarkColor: const Color(0xFF22C55E),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF334155),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  tempSelected.add(ave);
                                } else {
                                  tempSelected.remove(ave);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customController,
                              decoration: InputDecoration(
                                hintText: "Agregar otra avenida...",
                                hintStyle: const TextStyle(fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: () {
                              if (customController.text.trim().isNotEmpty) {
                                setModalState(() {
                                  tempSelected
                                      .add(customController.text.trim());
                                  customController.clear();
                                });
                              }
                            },
                            style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E)),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedAvenues = tempSelected;
                              state.currentDriver.vehicleInfo =
                                  "Avenidas: ${tempSelected.join(', ')}";
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Avenidas guardadas (${tempSelected.length}). Visible a pasajeros."),
                                backgroundColor: const Color(0xFF22C55E),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Confirmar y Hacer Visible",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = state.currentDriver;
    final activeTrip = state.currentTrip ?? state.incomingDriverRequest;

    // Obtener nodos de origen y destino si hay viaje activo
    LocationNode? origenNode;
    LocationNode? destinoNode;
    if (activeTrip != null) {
      try {
        origenNode = state.nodes.firstWhere(
          (n) =>
              n.nombre == activeTrip.origen ||
              n.nombre.contains(activeTrip.origen),
        );
      } catch (_) {
        origenNode = state.nodes.first;
      }
      try {
        destinoNode = state.nodes.firstWhere(
          (n) =>
              n.nombre == activeTrip.destino ||
              n.nombre.contains(activeTrip.destino),
        );
      } catch (_) {
        destinoNode =
            state.nodes.length > 1 ? state.nodes[1] : state.nodes.first;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                children: [
                  Text(
                    "Chofer • ${driver.nombre.split(' ').first}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    driver.vehicleInfo ?? 'Carpooling Empresarial',
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_bus_rounded,
                color: Colors.white, size: 20),
            tooltip: "Modo Chofer de Ruta Dedicada",
            onPressed: () => Navigator.pushNamed(context, '/ChoferRuta'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_road_rounded,
                color: Colors.white, size: 20),
            tooltip: "Configurar Avenidas",
            onPressed: _promptForAvenues,
          ),
          // Switch de conexión en línea
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Text(
                  state.isDriverOnline ? "En Línea" : "Offline",
                  style: TextStyle(
                    color: state.isDriverOnline
                        ? const Color(0xFF22C55E)
                        : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: state.isDriverOnline,
                    onChanged: (val) async {
                      if (val && _selectedAvenues.isEmpty) {
                        await _promptForAvenues();
                      }
                      await state.toggleDriverOnline(val);
                    },
                    activeThumbColor: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Mapa Geográfico OpenStreetMap en Pantalla Completa
            Positioned.fill(
              bottom: MediaQuery.of(context).size.height * 0.3,
              child: CampusFlutterMap(
                initialCenter: _mapCenter,
                initialZoom: 16.0,
                selectedOrigen: origenNode,
                selectedDestino: destinoNode,
                showDriverLocation: true,
                driverPosition: const LatLng(25.7255, -100.3125),
              ),
            ),

            // 2. Control Superior Flotante: Selector de Estado del Conductor
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: state.isDriverOnline
                            ? (state.driverStatus == 'En viaje'
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF22C55E))
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Estado: ${state.driverStatus}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E293B)),
                      ),
                    ),
                    // Botones de cambio rápido de estado
                    PopupMenuButton<String>(
                      onSelected: _setDriverState,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'Disponible', child: Text("🟢 Disponible")),
                        const PopupMenuItem(
                            value: 'En camino a origen',
                            child: Text("🔵 En camino a origen")),
                        const PopupMenuItem(
                            value: 'En viaje', child: Text("🟡 En viaje")),
                        const PopupMenuItem(
                            value: 'Desconectado',
                            child: Text("🔴 Desconectado")),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Text("Cambiar",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569))),
                            Icon(Icons.arrow_drop_down,
                                size: 18, color: Color(0xFF475569)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Panel Inferior de Servicios Asignados / Solicitudes
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (!state.isDriverOnline) ...[
                      // Estado Desconectado
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.power_settings_new,
                                  color: Colors.grey, size: 40),
                              const SizedBox(height: 8),
                              const Text(
                                "Actualmente estás desconectado",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Activa la disponibilidad para recibir solicitudes del parque.",
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _promptForAvenues();
                                  await state.toggleDriverOnline(true);
                                },
                                icon: const Icon(Icons.power_settings_new),
                                label: const Text("Activar disponibilidad"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (activeTrip == null) ...[
                      // Esperando solicitudes corporativas
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            if (_selectedAvenues.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alt_route,
                                        size: 16, color: Color(0xFF475569)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Avenidas: ${_selectedAvenues.join(', ')}",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF334155)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _promptForAvenues,
                                      child: const Text("Cambiar",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF22C55E),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E)
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.radar,
                                      color: Color(0xFF22C55E), size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Buscando solicitudes del parque industrial...",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF1E293B)),
                                      ),
                                      Text(
                                        "Zona activa: Santa Catarina, Apodaca y ruta aeropuerto",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFF86EFAC)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF22C55E), size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sistema de asignación activo. Solicitudes en tiempo real.',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF166534),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Servicio Asignado / Solicitud Activa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activeTrip.estado.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            "+${activeTrip.costoCreditos} Créditos",
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Pasajero: ${activeTrip.pasajeroNombre}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),

                      // Ruta
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.my_location,
                                    size: 16, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 8),
                                const Text("Origen: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    activeTrip.origen,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Color(0xFF22C55E)),
                                const SizedBox(width: 8),
                                const Text("Destino: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    activeTrip.destino,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botones de acción del chofer
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/CodigoQR'),
                              icon: const Icon(Icons.qr_code_scanner, size: 18),
                              label: const Text("Escanear QR"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1E293B),
                                side:
                                    const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (state.driverStatus != 'En viaje') ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  state.acceptDriverTrip();
                                  _setDriverState('En viaje');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "¡Viaje aceptado! Dirígete a la parada del pasajero."),
                                      backgroundColor: Color(0xFF22C55E),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Aceptar"),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  state.completeCurrentTrip();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "¡Viaje completado exitosamente! Créditos transferidos."),
                                      backgroundColor: Color(0xFF22C55E),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Finalizar"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 0),
    );
  }
}
