import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../widgets/bottom_nav_bar.dart';

class HistorialViajesScreen extends StatelessWidget {
  const HistorialViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParkRideState();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Historial de Viajes",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: state.tripHistory.length,
          itemBuilder: (context, index) {
            final trip = state.tripHistory[index];
            final isCompleted = trip.estado == "Completado";

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF22C55E).withOpacity(0.12) : Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: isCompleted ? const Color(0xFF22C55E) : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${trip.origen} ➔ ${trip.destino}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Conductor: ${trip.conductorNombre} · ${trip.vehiculoInfo}",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          "Fecha: ${trip.timestamp.day}/${trip.timestamp.month}/${trip.timestamp.year}",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${trip.costoCreditos} pts",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCompleted ? const Color(0xFF22C55E) : Colors.grey,
                        ),
                      ),
                      Text(
                        trip.estado,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? const Color(0xFF22C55E) : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 2),
    );
  }
}
