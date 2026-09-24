import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/interactive_map.dart';

class ModoConductor extends StatefulWidget {
  const ModoConductor({super.key});

  @override
  State<ModoConductor> createState() => _ModoConductorState();
}

class _ModoConductorState extends State<ModoConductor> {
  final state = ParkRideState();
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    final driver = state.currentDriver;

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.badge_outlined, color: Color(0xFF22C55E)),
            const SizedBox(width: 8),
            Text(
              "Modo Conductor - ${driver.nombre}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF0F172A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0xFF22C55E) : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOnline ? "Estás en línea (Recibiendo solicitudes)" : "Desconectado",
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  Switch(
                    value: isOnline,
                    onChanged: (val) => setState(() => isOnline = val),
                    activeColor: const Color(0xFF22C55E),
                  ),
                ],
              ),
            ),

            // Live Industrial Map
            const Expanded(
              child: IndustrialMapCanvas(
                selectedOrigen: "Nave A",
                selectedDestino: "Comedor B",
              ),
            ),

            // Incoming Ride Request Card
            if (isOnline) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "NUEVO VIAJE ENTRANTE",
                            style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        const Text(
                          "+12 Créditos",
                          style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Pasajero: Raúl Jiménez Beltrán",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.my_location, size: 16, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 6),
                        const Text("Origen: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Text("Nave A", style: TextStyle(fontSize: 13)),
                        const Spacer(),
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF22C55E)),
                        const SizedBox(width: 6),
                        const Text("Destino: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Text("Comedor B", style: TextStyle(fontSize: 13)),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/CodigoQR'),
                            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF1E293B)),
                            label: const Text("Escanear QR", style: TextStyle(color: Color(0xFF1E293B))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E293B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("¡Viaje Aceptado! Dirígete a Nave A."),
                                  backgroundColor: Color(0xFF22C55E),
                                ),
                              );
                              Navigator.pushNamed(context, '/ViajeEnCurso');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Aceptar Viaje"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 0),
    );
  }
}
