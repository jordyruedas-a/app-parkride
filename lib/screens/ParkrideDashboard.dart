import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../widgets/bottom_nav_bar.dart';

class ParkrideDashboard extends StatefulWidget {
  const ParkrideDashboard({super.key});

  @override
  State<ParkrideDashboard> createState() => _ParkrideDashboardState();
}

class _ParkrideDashboardState extends State<ParkrideDashboard> {
  final state = ParkRideState();

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hola, ${user.nombre}",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "Mi Movilidad",
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/ParkrideProfileSettings'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.person, color: Color(0xFF22C55E), size: 28),
                    ),
                  ),
                ],
              ),
            ),

            // Main Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Active Trip Notice if exists
                    if (state.currentTrip != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.electric_car, color: Colors.white, size: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "¡Tienes un Viaje en Curso!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "${state.currentTrip!.origen} -> ${state.currentTrip!.destino}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/ViajeEnCurso'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1D4ED8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Ver"),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Section Title: Opciones de Traslado Interno
                    const Text(
                      "Opciones de Traslado Interno",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Grid of 4 Transfer Options
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.25,
                      children: [
                        _buildOptionCard(
                          context,
                          title: "Viaje Bajo Demanda",
                          subtitle: "Carritos y Vans",
                          icon: Icons.electric_car_rounded,
                          color: const Color(0xFF22C55E),
                          onTap: () => Navigator.pushNamed(context, '/SolicitarViaje'),
                        ),
                        _buildOptionCard(
                          context,
                          title: "Reserva Vehículo",
                          subtitle: "Asignación rápida",
                          icon: Icons.time_to_leave_rounded,
                          color: const Color(0xFF3B82F6),
                          onTap: () => Navigator.pushNamed(context, '/SolicitarViaje'),
                        ),
                        _buildOptionCard(
                          context,
                          title: "Ruta Shuttle",
                          subtitle: "Horarios fijos",
                          icon: Icons.airport_shuttle_rounded,
                          color: const Color(0xFFA855F7),
                          onTap: () => Navigator.pushNamed(context, '/SolicitarViaje'),
                        ),
                        _buildOptionCard(
                          context,
                          title: "E-Scooters & Bicis",
                          subtitle: "Micromovilidad",
                          icon: Icons.two_wheeler_rounded,
                          color: const Color(0xFFF59E0B),
                          onTap: () => Navigator.pushNamed(context, '/SolicitarViaje'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section Title: Mi Billetera y Sostenibilidad
                    const Text(
                      "Mi Billetera y Sostenibilidad",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Wallet & ESG Cards
                    Row(
                      children: [
                        // Card 1: Créditos
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                                    const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF22C55E)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Créditos",
                                        style: TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "${user.saldoCreditos} / 500",
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Saldo Actual",
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: user.saldoCreditos / 500,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  color: const Color(0xFF22C55E),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Card 2: CO2 Evitado
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                                    const Icon(Icons.eco_rounded, color: Color(0xFF10B981)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Ahorro",
                                        style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "${state.totalCo2SavingsKg.toStringAsFixed(1)} Kg",
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "CO₂ Evitado",
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: (state.totalCo2SavingsKg / 10.0).clamp(0.0, 1.0),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  color: const Color(0xFF10B981),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Switch to Driver Mode
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.badge, color: Colors.white),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Modo Conductor",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Gana créditos transportando compañeros",
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: state.isDriverModeActive,
                            onChanged: (val) {
                              state.toggleDriverMode(val);
                              if (val) {
                                Navigator.pushNamed(context, '/ModoConductor');
                              }
                            },
                            activeColor: const Color(0xFF22C55E),
                          ),
                        ],
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

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
