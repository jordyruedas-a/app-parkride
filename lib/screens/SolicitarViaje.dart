import 'package:flutter/material.dart';
import '../models/parkride_models.dart';
import '../services/location_service.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/campus_flutter_map.dart';

class SolicitarViaje extends StatefulWidget {
  const SolicitarViaje({super.key});

  @override
  State<SolicitarViaje> createState() => _SolicitarViajeState();
}

class _SolicitarViajeState extends State<SolicitarViaje> {
  final state = ParkRideState();

  late String origen;
  late String destino;
  LocationNode? _currentOrigin;
  TransportOption? selectedOption;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    origen = state.nodes.first.nombre;
    destino = state.nodes.length > 1
        ? state.nodes[1].nombre
        : state.nodes.first.nombre;
    selectedOption = state.availableOptions.first;
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final location =
        await ParkRideLocationService().getCurrentLocationWithAddress();
    if (!mounted || location == null) {
      if (mounted) {
        setState(
            () => origen = 'Activa la ubicación para establecer tu origen');
      }
      return;
    }

    setState(() {
      origen = location.address;
      _currentOrigin = LocationNode(
        id: 'current-location',
        nombre: location.address,
        zona: 'Ubicación actual',
        iconType: 'my_location',
        latitude: location.coordinates.latitude,
        longitude: location.coordinates.longitude,
      );
    });
  }

  void _confirmTrip() async {
    if (selectedOption == null) return;
    final destinationNode =
        state.nodes.where((node) => node.nombre == destino).firstOrNull;
    if (_currentOrigin == null || destinationNode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa tu ubicación y selecciona un destino válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_currentOrigin!.id == destinationNode.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("El origen y destino deben ser nodos distintos del parque."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await state.requestTrip(
        origen: _currentOrigin!,
        destino: destinationNode,
        option: selectedOption!,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/ViajeEnCurso');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo crear el viaje: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Solicitar Viaje",
          style:
              TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppLogo(size: 32, borderRadius: 8),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Node Selector Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location,
                                  color: Color(0xFF3B82F6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Origen actual',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      origen,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Actualizar ubicación',
                                onPressed: _loadCurrentLocation,
                                icon: const Icon(Icons.refresh_rounded),
                              ),
                            ],
                          ),

                          const Divider(height: 20),

                          // Destino Dropdown
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF22C55E)),
                              const SizedBox(width: 12),
                              const Text("Destino: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: destino,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: state.nodes.map((n) {
                                    return DropdownMenuItem<String>(
                                      value: n.nombre,
                                      child: Text(n.nombre,
                                          style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null)
                                      setState(() => destino = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Interactive Mini Live Map Render
                    const Text(
                      "Mapa de Rutas (OpenStreetMap)",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 180,
                      child: CampusFlutterMap(
                        initialCenter: _currentOrigin?.latLng ??
                            ParkRideLocationService.fallbackLocation,
                        initialZoom: 14,
                        selectedOrigen: _currentOrigin,
                        selectedDestino: state.nodes
                            .where((node) => node.nombre == destino)
                            .firstOrNull,
                        routes: state.routes,
                        transportFilter: selectedOption?.id == 'OPT_02'
                            ? 'van'
                            : selectedOption?.id == 'OPT_03'
                                ? 'carpool'
                                : 'bus',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Opciones de Transporte
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Opciones de Transporte",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Saldo: ${state.currentUser.saldoCreditos} pts",
                          style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Transport Option Cards
                    Column(
                      children: state.availableOptions.map((opt) {
                        final isSelected = selectedOption?.id == opt.id;
                        return GestureDetector(
                          onTap: () => setState(() => selectedOption = opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF22C55E)
                                      .withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getIconData(opt.iconName),
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        "${opt.etaMinutes} mins de llegada · Eco: -${opt.co2SavingsKg} kg CO₂",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${opt.costCredits} Créditos",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const Text(
                                      "Pago virtual",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Confirm Action Button
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _confirmTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Confirmar Viaje (${selectedOption?.costCredits ?? 0} Créditos)",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 1),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'airport_shuttle':
        return Icons.airport_shuttle_rounded;
      case 'people':
        return Icons.people_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }
}
