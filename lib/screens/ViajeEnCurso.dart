import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
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
    final trip = state.currentTrip ?? state.tripHistory.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Viaje en Curso",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF22C55E)),
            onPressed: () => Navigator.pushNamed(context, '/CodigoQR'),
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
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
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
                            color: Colors.black.withOpacity(0.04),
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
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.timer_outlined, color: Color(0xFF3B82F6)),
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
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Conductor asignado", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                    Text(
                                      trip.conductorNombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                                    ),
                                    const Text("Placa: PRK-2048 · Unidad Eléctrica", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Trip Stats Metrics
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetric("ETA", "${trip.duracionMin} min"),
                              _buildMetric("Distancia", "${trip.distanciaKm} km"),
                              _buildMetric("Costo", "${trip.costoCreditos} pts"),
                              _buildMetric("CO₂ Ahorrado", "${trip.co2EvitadoKg} kg"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Show QR Button
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/CodigoQR'),
                            icon: const Icon(Icons.qr_code_2, color: Color(0xFF22C55E)),
                            label: const Text("Ver Código QR de Abordaje", style: TextStyle(color: Color(0xFF22C55E))),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 46),
                              side: const BorderSide(color: Color(0xFF22C55E)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        content: Text("Viaje finalizado exitosamente. ¡Gracias por contribuir al medio ambiente!"),
                        backgroundColor: Color(0xFF22C55E),
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/ParkrideDashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Finalizar Viaje", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}
