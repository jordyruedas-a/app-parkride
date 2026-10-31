import 'package:flutter/material.dart';
import '../services/parkride_state.dart';
import '../services/parkride_business_rules.dart';
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
  final List<Map<String, String>> _vehicles = [
    {
      'marca': 'Toyota',
      'modelo': 'Corolla',
      'placa': 'ABC-1234',
      'tipo': 'Sedán',
      'aseguradora': 'Sin especificar',
      'poliza': 'Sin especificar',
    },
  ];

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

  bool get _isDriverProfile {
    final role = state.currentUser.rol.toLowerCase();
    return role.contains('chofer') ||
        role.contains('ruta') ||
        role.contains('driver');
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

  Future<void> _showVehicleForm() async {
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final typeController = TextEditingController();
    final colorController = TextEditingController();
    final insurerController = TextEditingController();
    final policyController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Agregar vehículo',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: plateController,
                  decoration:
                      const InputDecoration(labelText: 'Matrícula/Placa'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration:
                      const InputDecoration(labelText: 'Tipo de unidad'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: insurerController,
                  decoration: const InputDecoration(labelText: 'Aseguradora'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: policyController,
                  decoration:
                      const InputDecoration(labelText: 'Número de póliza'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (brandController.text.trim().isEmpty ||
                          modelController.text.trim().isEmpty ||
                          plateController.text.trim().isEmpty ||
                          typeController.text.trim().isEmpty) {
                        return;
                      }
                      _vehicles.add({
                        'marca': brandController.text.trim(),
                        'modelo': modelController.text.trim(),
                        'placa': plateController.text.trim(),
                        'tipo': typeController.text.trim(),
                        'color': colorController.text.trim().isEmpty
                            ? 'Sin especificar'
                            : colorController.text.trim(),
                        'aseguradora': insurerController.text.trim().isEmpty
                            ? 'Sin especificar'
                            : insurerController.text.trim(),
                        'poliza': policyController.text.trim().isEmpty
                            ? 'Sin especificar'
                            : policyController.text.trim(),
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Guardar vehículo'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = state.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style:
              TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF1E293B)),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Editar perfil',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                                labelText: 'Nombre completo'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Nombre requerido'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration:
                                const InputDecoration(labelText: 'Teléfono'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Teléfono requerido'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _departmentController,
                            decoration: const InputDecoration(
                                labelText: 'Empresa / Departamento'),
                          ),
                          const SizedBox(height: 12),
                          if (_isDriverProfile)
                            TextFormField(
                              controller: _vehicleController,
                              decoration: const InputDecoration(
                                  labelText: 'Vehículo / Unidad'),
                            ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _saveProfile();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Guardar cambios'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.rol,
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
                'Datos personales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              _buildProfileField('Nombre', user.nombre),
              _buildProfileField('Correo', user.correo),
              _buildProfileField('Teléfono', user.telefono),
              _buildProfileField('Empresa', user.empresa),
              if (_isDriverProfile) ...[
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mis Vehículos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showVehicleForm,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar Vehículo'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_vehicles.isEmpty)
                  const Text('No hay vehículos registrados todavía.')
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _vehicles.map((vehicle) {
                      return Container(
                        width: 180,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle['marca'] ?? ''} ${vehicle['modelo'] ?? 'Vehículo'}'
                                  .trim(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 8),
                            Text('Placa: ${vehicle['placa'] ?? '-'}'),
                            Text('Tipo: ${vehicle['tipo'] ?? '-'}'),
                            Text(
                                'Color: ${vehicle['color'] ?? 'Sin especificar'}'),
                            Text(
                                'Aseguradora: ${vehicle['aseguradora'] ?? 'Sin especificar'}'),
                            Text(
                                'Póliza: ${vehicle['poliza'] ?? 'Sin especificar'}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/ReportesESG'),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Reportar incidencia'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/ParkrideLogin', (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ParkRideBusinessRules.isDriverRole(user.rol)
          ? const ParkRideBottomNavBar(
              currentIndex: 3,
              items: ParkRideBottomNavBar.driverItems,
            )
          : const ParkRideBottomNavBar(currentIndex: 3),
    );
  }
}
