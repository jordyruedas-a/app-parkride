import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/parkride_models.dart';
import '../services/airport_route_service.dart';
import '../services/location_service.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/campus_flutter_map.dart';

class ParkrideDashboard extends StatefulWidget {
  const ParkrideDashboard({super.key});

  @override
  State<ParkrideDashboard> createState() => _ParkrideDashboardState();
}

class _ParkrideDashboardState extends State<ParkrideDashboard> {
  final state = ParkRideState();

  LocationNode? selectedOrigen;
  LocationNode? selectedDestino;
  TransportOption? selectedOption;
  final TextEditingController _searchController = TextEditingController();
  late LatLng _mapCenter;

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
    _mapCenter = state.userCurrentLocation;
    _initializeDefaultNodes();
    _refreshUserLocation();
    selectedOption = state.availableOptions.first;
    state.refreshNearestRoute();
  }

  Future<void> _refreshUserLocation() async {
    final currentPosition =
        await ParkRideLocationService().getCurrentPosition();
    if (!mounted || currentPosition == null) {
      return;
    }

    setState(() {
      state.userCurrentLocation = currentPosition;
      _mapCenter = currentPosition;

      final nearestOrigin = state.getNearestNode(currentPosition);
      final nextNodes =
          state.nodes.where((node) => node.id != nearestOrigin.id).toList();
      final nearestDestination = nextNodes.isNotEmpty
          ? state.getNearestNode(currentPosition, exclude: nearestOrigin)
          : nearestOrigin;

      selectedOrigen ??= nearestOrigin;
      selectedDestino ??= nearestDestination;
    });
  }

  void _initializeDefaultNodes() {
    if (state.nodes.isEmpty) {
      selectedOrigen = null;
      selectedDestino = null;
      return;
    }

    selectedOrigen ??= state.nodes.first;
    selectedDestino ??=
        state.nodes.length > 1 ? state.nodes[1] : state.nodes.first;
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Selecciona tu destino en el parque",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar parada, zona o destino...",
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF22C55E)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: state.nodes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final node = state.nodes[index];
                        final isSelected = selectedDestino?.id == node.id;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF22C55E)
                                    .withValues(alpha: 0.12),
                            child: Icon(
                              isSelected ? Icons.check : Icons.school,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF15803D),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            node.nombre,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "${node.zona} • Lat: ${node.latitude.toStringAsFixed(4)}, Lng: ${node.longitude.toStringAsFixed(4)}",
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          onTap: () {
                            setState(() {
                              selectedDestino = node;
                            });
                            Navigator.pop(ctx);
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
      },
    );
  }

  void _requestTripDirect() {
    if (selectedOrigen == null ||
        selectedDestino == null ||
        selectedOption == null) return;
    if (selectedOrigen!.id == selectedDestino!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "El origen y destino deben ser puntos distintos del parque."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    state.requestTrip(
      origen: selectedOrigen!,
      destino: selectedDestino!,
      option: selectedOption!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "¡Viaje solicitado a ${selectedDestino!.nombre}! Conductor asignado."),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );

    Navigator.pushNamed(context, '/ViajeEnCurso');
  }

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Mapa Base con flutter_map (OpenStreetMap) en Ciudad Universitaria
            Positioned.fill(
              bottom: MediaQuery.of(context).size.height *
                  0.35, // Dinámico según altura de pantalla
              child: CampusFlutterMap(
                initialCenter: _mapCenter,
                initialZoom: 16.2,
                selectedOrigen: selectedOrigen,
                selectedDestino: selectedDestino,
                onNodeSelected: (node) {
                  setState(() {
                    if (selectedOrigen == null) {
                      selectedOrigen = node;
                    } else if (selectedDestino == null ||
                        selectedDestino!.id == node.id) {
                      selectedDestino = node;
                    } else {
                      selectedDestino = node;
                    }
                  });
                },
                showDriverLocation: true,
              ),
            ),

            // 2. Encabezado Flotante Superior (Perfil, Búsqueda y Botón de Chofer)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barra de Estado Superior
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 34, borderRadius: 10),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Hola, ${user.nombre.split(' ').first}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${user.saldoCreditos} Créditos Verdes",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Botón de cambio rápido a Modo Conductor
                        OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/ModoConductor'),
                          icon: const Icon(Icons.directions_bus,
                              size: 16, color: Color(0xFF1E293B)),
                          label: const Text(
                            "Chofer",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/ParkrideProfileSettings'),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                color: Color(0xFF22C55E), size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.route_rounded,
                            color: Color(0xFF86EFAC), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AirportRouteService.buildRouteRecommendationText(
                                state.userCurrentLocation),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Barra de Búsqueda de Destinos con flutter_map / CU
                  GestureDetector(
                    onTap: _showDestinationPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: Color(0xFF22C55E), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedDestino == null
                                  ? "¿A dónde necesitas ir?"
                                  : "Destino: ${selectedDestino!.nombre}",
                              style: TextStyle(
                                color: selectedDestino == null
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF1E293B),
                                fontSize: 13,
                                fontWeight: selectedDestino == null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Panel Inferior Moderno para el Pasajero
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
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de arrastre
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

                    // Chip de Ruta Seleccionada (Origen -> Destino)
                    Row(
                      children: [
                        const Icon(Icons.my_location,
                            size: 16, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${selectedOrigen?.nombre.split(' - ').first ?? 'Punto de origen'} → ${selectedDestino?.nombre.split(' - ').first ?? 'Punto de destino'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: _showDestinationPicker,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 24),
                          ),
                          child: const Text(
                            "Cambiar",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Opciones de Transporte Universitario
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.availableOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final option = state.availableOptions[index];
                          final isSelected = selectedOption?.id == option.id;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedOption = option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 120,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF22C55E)
                                        .withValues(alpha: 0.08)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        option.iconName == 'airport_shuttle'
                                            ? Icons.airport_shuttle
                                            : (option.iconName == 'people'
                                                ? Icons.people_rounded
                                                : Icons.directions_bus_rounded),
                                        size: 22,
                                        color: isSelected
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFF475569),
                                      ),
                                      Text(
                                        "${option.etaMinutes} min",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    option.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${option.costCredits} cr",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "-${option.co2SavingsKg}kg",
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón Principal de Acción "Solicitar Traslado en Campus"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _requestTripDirect,
                        icon: const Icon(Icons.flash_on,
                            color: Colors.white, size: 20),
                        label: Text(
                          selectedOption == null
                              ? "Solicitar Traslado"
                              : "Solicitar ${selectedOption!.title}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 0),
    );
  }
}
