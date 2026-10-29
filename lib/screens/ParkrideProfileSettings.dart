import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav_bar.dart';

class ParkrideProfileSettings extends StatefulWidget {
  const ParkrideProfileSettings({super.key});

  @override
  State<ParkrideProfileSettings> createState() =>
      _ParkrideProfileSettingsState();
}

class _ParkrideProfileSettingsState extends State<ParkrideProfileSettings> {
  final state = ParkRideState();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _departmentController;
  late final TextEditingController _vehicleController;

  @override
  void initState() {
    super.initState();
    final user = state.currentUser;
    _nameController = TextEditingController(text: user.nombre);
    _phoneController = TextEditingController(text: user.telefono);
    _departmentController = TextEditingController(text: user.departamento);
    _vehicleController = TextEditingController(text: user.vehicleInfo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final user = state.currentUser;
    state.currentUser = user.copyWith(
      nombre: _nameController.text.trim(),
      telefono: _phoneController.text.trim(),
      departamento: _departmentController.text.trim(),
      vehicleInfo: _vehicleController.text.trim().isEmpty
          ? null
          : _vehicleController.text.trim(),
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente.'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi Perfil y Configuración',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Row(
                    children: [
                      const AppLogo(size: 64, borderRadius: 18, showBorder: true),
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
                              'ID: ${user.idEmpleado}',
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
                const Text(
                  'Datos Personales',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre completo'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Nombre requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Teléfono requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(labelText: 'Departamento/Empresa'),
                      ),
                      if (user.hasVehicle || user.rol.toLowerCase().contains('ruta') || user.rol.toLowerCase().contains('chofer')) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _vehicleController,
                          decoration: const InputDecoration(labelText: 'Vehículo / Información de ruta'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: const Text('Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/ParkrideLogin', (route) => false);
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
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
      ),
      bottomNavigationBar: const ParkRideBottomNavBar(currentIndex: 4),
    );
  }

}
