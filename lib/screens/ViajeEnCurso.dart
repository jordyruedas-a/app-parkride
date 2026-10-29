import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/interactive_map.dart';

class ViajeEnCurso extends StatefulWidget {
  const ViajeEnCurso({super.key});

  @override
  State<ViajeEnCurso> createState() => _ViajeEnCursoState();
}

class _ViajeEnCursoState extends State<ViajeEnCurso> {
  final state = ParkRideState();

  @override
  Widget build(BuildContext context) {
    final trip = state.currentTrip ??
        (state.tripHistory.isNotEmpty ? state.tripHistory.first : null);

    if (trip == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Viaje en Curso",
            style: TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_outlined,
                    size: 64, color: Color(0xFF94A3B8)),
                const SizedBox(height: 16),
                const Text(
                  "No tienes un traslado activo",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Solicita un viaje en Camión, Van o Carpooling desde el inicio para visualizar tu trayecto en tiempo real.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/ParkrideDashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Ir al Inicio"),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 1),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Viaje en Curso",
          style:
              TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "EN TRÁNSITO INTERNO",
                            style: TextStyle(
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Map View
                    SizedBox(
                      height: 220,
                      child: IndustrialMapCanvas(
                        selectedOrigen: trip.origen,
                        selectedDestino: trip.destino,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${trip.origen} -> ${trip.destino}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Vehículo: ${trip.vehiculoInfo}",
                                    style: const TextStyle(
                                        color: Color(0xFF64748B), fontSize: 13),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.timer_outlined,
                                    color: Color(0xFF3B82F6)),
                              ),
                            ],
                          ),

                          const Divider(height: 28),

                          // Driver info
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF1E293B),
                                radius: 24,
                                child: Text(
                                  trip.conductorNombre[0],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Conductor asignado",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8))),
                                    Text(
                                      trip.conductorNombre,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B)),
                                    ),
                                    const Text(
                                        "Placa: PRK-2048 · Unidad Eléctrica",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Trip Stats Metrics
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.spaceAround,
                            children: [
                              _buildMetric("ETA", "${trip.duracionMin} min"),
                              _buildMetric(
                                  "Distancia", "${trip.distanciaKm} km"),
                              _buildMetric(
                                  "Costo", "${trip.costoCreditos} pts"),
                              _buildMetric(
                                  "CO₂ Ahorrado", "${trip.co2EvitadoKg} kg"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Show Passenger QR Dialog Button
                          OutlinedButton.icon(
                            onPressed: () =>
                                _showPassengerQRDialog(context, trip),
                            icon: const Icon(Icons.qr_code_2,
                                color: Color(0xFF22C55E)),
                            label: const Text("Ver Mi Pase de Abordaje (QR)",
                                style: TextStyle(
                                    color: Color(0xFF22C55E),
                                    fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 46),
                              side: const BorderSide(color: Color(0xFF22C55E)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Finish Trip button
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    state.finishCurrentTrip();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Viaje finalizado exitosamente. ¡Gracias por contribuir al medio ambiente!"),
                        backgroundColor: Color(0xFF22C55E),
                      ),
                    );
                    Navigator.pushReplacementNamed(
                        context, '/ParkrideDashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Finalizar Viaje",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 1),
    );
  }

  void _showPassengerQRDialog(BuildContext context, dynamic trip) {
    final expiryTime =
        trip.qrExpiresAt ?? trip.timestamp.add(const Duration(minutes: 15));
    final remainingMinutes =
        expiryTime.difference(DateTime.now()).inMinutes.clamp(0, 15);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: Color(0xFF22C55E), size: 28),
            SizedBox(width: 10),
            Text(
              "Pase de Abordaje",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(150, 150),
                          painter: _QrMatrixPainter(trip.qrCode ?? 'PR-QR-001'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4),
                            ],
                          ),
                          child: const AppLogo(size: 24, borderRadius: 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    trip.qrCode ?? "PR-QR-001",
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.1,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pasajero: ${trip.pasajeroNombre}",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Color(0xFF16A34A), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Vigencia: $remainingMinutes min restantes (máx. 15m)",
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Muestra este código al chofer para registrar tu abordaje seguro.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar",
                style: TextStyle(
                    color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E293B))),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  final String data;
  const _QrMatrixPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF0F172A);
    const int cells = 15;
    final cellSize = size.width / cells;

    // Deterministic bit generator based on string
    final seed = data.hashCode.abs();

    for (int r = 0; r < cells; r++) {
      for (int c = 0; c < cells; c++) {
        // Draw standard QR finder patterns in 3 corners
        final isTopLeftFinder = (r < 4 && c < 4);
        final isTopRightFinder = (r < 4 && c >= cells - 4);
        final isBottomLeftFinder = (r >= cells - 4 && c < 4);

        if (isTopLeftFinder || isTopRightFinder || isBottomLeftFinder) {
          // outer ring or center dot
          final localR = isBottomLeftFinder ? r - (cells - 4) : r;
          final localC = isTopRightFinder ? c - (cells - 4) : c;
          if (localR == 0 ||
              localR == 3 ||
              localC == 0 ||
              localC == 3 ||
              (localR == 1 && localC == 1) ||
              (localR == 2 && localC == 2)) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(c * cellSize + 0.5, r * cellSize + 0.5,
                    cellSize - 1, cellSize - 1),
                const Radius.circular(1.5),
              ),
              paintDark,
            );
          }
        } else {
          // Inner data pattern
          final bit = ((seed ^ (r * 31 + c * 17)) * 2654435761) & 0xFF;
          if (bit % 2 == 0) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(c * cellSize + 1, r * cellSize + 1, cellSize - 2,
                    cellSize - 2),
                const Radius.circular(1),
              ),
              paintDark,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) =>
      oldDelegate.data != data;
}
