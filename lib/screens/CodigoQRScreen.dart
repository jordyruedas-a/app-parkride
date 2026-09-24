import 'package:flutter/material.dart';
import '../services/parkride_state.dart';

class CodigoQRScreen extends StatelessWidget {
  const CodigoQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ParkRideState().currentTrip ?? ParkRideState().tripHistory.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Código QR de Abordaje", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Código de Viaje Activo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Muéstralo al conductor al abordar el vehículo",
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Big QR Mockup box with code
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 120, color: Color(0xFF1E293B)),
                        const SizedBox(height: 8),
                        Text(
                          trip.qrCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF22C55E)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "${trip.origen} ➔ ${trip.destino}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Conductor: ${trip.conductorNombre} (${trip.vehiculoInfo})",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Código QR copiado al portapapeles.")),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text("Compartir Código"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
