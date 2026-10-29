import 'package:flutter/material.dart';
import '../models/parkride_models.dart';
import '../services/parkride_state.dart';
import 'campus_flutter_map.dart';

/// Mapa interactivo de Ciudad Universitaria UANL basado en OpenStreetMap y flutter_map.
/// Reemplaza el canvas estático anterior con mapas reales, gratuitos y geolocalizados.
class IndustrialMapCanvas extends StatelessWidget {
  final String? selectedOrigen;
  final String? selectedDestino;
  final Function(LocationNode)? onNodeSelected;
  final bool isMiniMap;

  const IndustrialMapCanvas({
    super.key,
    this.selectedOrigen,
    this.selectedDestino,
    this.onNodeSelected,
    this.isMiniMap = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = ParkRideState();

    LocationNode? origenNode;
    LocationNode? destinoNode;

    if (selectedOrigen != null) {
      try {
        origenNode = state.nodes.firstWhere(
          (n) => n.nombre.toLowerCase().contains(selectedOrigen!.toLowerCase()),
        );
      } catch (_) {}
    }

    if (selectedDestino != null) {
      try {
        destinoNode = state.nodes.firstWhere(
          (n) =>
              n.nombre.toLowerCase().contains(selectedDestino!.toLowerCase()),
        );
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(isMiniMap ? 16 : 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMiniMap ? 16 : 20),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CampusFlutterMap(
          initialCenter: ParkRideState.campusCenter,
          initialZoom: isMiniMap ? 15.5 : 16.2,
          selectedOrigen: origenNode,
          selectedDestino: destinoNode,
          onNodeSelected: onNodeSelected,
          showDriverLocation: true,
          isInteractive: !isMiniMap,
        ),
      ),
    );
  }
}
