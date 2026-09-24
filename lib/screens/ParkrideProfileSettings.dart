import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../widgets/bottom_nav_bar.dart';

class ParkrideProfileSettings extends StatefulWidget {
  const ParkrideProfileSettings({super.key});

  @override
  State<ParkrideProfileSettings> createState() => _ParkrideProfileSettingsState();
}

class _ParkrideProfileSettingsState extends State<ParkrideProfileSettings> {
  final state = ParkRideState();

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mi Perfil y Configuración",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar Card
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF22C55E),
                      child: Text(
                        user.nombre.substring(0, 1),
                        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "ID: ${user.idEmpleado}",
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.correo,
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Datos Personales
              const Text(
                "Datos Personales",
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.person_outline, "Nombre completo", user.nombre),
                    const Divider(),
                    _buildInfoTile(Icons.email_outlined, "Email corporativo", user.correo),
                    const Divider(),
                    _buildInfoTile(Icons.business_outlined, "Departamento", user.departamento),
                    const Divider(),
                    _buildInfoTile(Icons.phone_outlined, "Teléfono", user.telefono),
                    const Divider(),
                    _buildInfoTile(Icons.access_time_outlined, "Turno Asignado", user.turno),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mi Vehículo Registrado (Para Conductores)
              const Text(
                "Mi Vehículo (Modo Conductor)",
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.electric_car, color: Color(0xFF22C55E), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.vehicleInfo ?? "Nissan Leaf 2024",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                          const Text("Placa PRK-2048 · Eléctrico", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const Text("Estac: Zona E2 · Cajón 118", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("ACTIVO", style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Métodos de Pago Virtual
              const Text(
                "Método de Pago Virtual",
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, color: Color(0xFF3B82F6), size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Créditos por Nómina", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                          Text("Cuota mensual asignada por la empresa", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("PREDETERMINADO", style: TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/ParkrideLogin', (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }
}
