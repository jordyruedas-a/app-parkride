import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/parkride_business_rules.dart';
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
  static const _avenuesByMunicipality = <String, List<String>>{
    'guadalupe': ['Av. Israel Cavazos', 'Av. Pablo Livas', 'Av. Eloy Cavazos'],
    'san nicolás': ['Av. Ruiz Cortines', 'Av. Sendero', 'Av. Rómulo Garza'],
    'apodaca': ['Av. Miguel Alemán', 'Av. Concordia'],
    'monterrey': [
      'Av. Constitución',
      'Av. Colón',
      'Av. Garza Sada',
      'Av. Pino Suárez',
    ],
  };

  final _state = ParkRideState();
  bool _saving = false;

  bool get _isRouteDriver =>
      ParkRideBusinessRules.isDriverRole(_state.currentUser.rol);

  List<Map<String, dynamic>> get _vehicles =>
      List<Map<String, dynamic>>.from(_state.currentUser.carpoolVehicles);

  Future<void> _saveVolunteer({
    required List<Map<String, dynamic>> vehicles,
    required List<String> avenues,
    required bool enabled,
  }) async {
    setState(() => _saving = true);
    try {
      await _state.saveVolunteerProfile(
        vehicles: vehicles,
        avenues: avenues,
        enabled: enabled,
      );
      if (mounted) setState(() {});
    } on StateError catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo guardar la configuración. Intenta de nuevo.',
            error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor:
          error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
    ));
  }

  Future<Map<String, dynamic>?> _vehicleForm(
      {Map<String, dynamic>? existing}) async {
    final controllers = <String, TextEditingController>{
      for (final name in [
        'brand',
        'model',
        'color',
        'plate',
        'insurer',
        'policy'
      ])
        name: TextEditingController(text: existing?[name]?.toString() ?? ''),
    };
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(existing == null ? 'Agregar vehículo' : 'Editar vehículo',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (final field in [
              ('brand', 'Marca'),
              ('model', 'Modelo'),
              ('color', 'Color'),
              ('plate', 'Placa / matrícula'),
              ('insurer', 'Aseguradora'),
              ('policy', 'Número de póliza'),
            ]) ...[
              TextField(
                  controller: controllers[field.$1],
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: field.$2)),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: () {
                if (controllers.values
                    .any((controller) => controller.text.trim().isEmpty)) {
                  _showMessage('Completa todos los datos del vehículo.',
                      error: true);
                  return;
                }
                Navigator.pop(context, {
                  for (final entry in controllers.entries)
                    entry.key: entry.value.text.trim(),
                });
              },
              child: const Text('Guardar vehículo'),
            ),
          ]),
        ),
      ),
    );
    for (final controller in controllers.values) {
      controller.dispose();
    }
    return result;
  }

  Future<void> _addOrEditVehicle([int? index]) async {
    final vehicles = _vehicles;
    final vehicle =
        await _vehicleForm(existing: index == null ? null : vehicles[index]);
    if (vehicle == null) return;
    if (index == null) {
      vehicles.add(vehicle);
    } else {
      vehicles[index] = vehicle;
    }
    await _saveVolunteer(
      vehicles: vehicles,
      avenues: _state.currentUser.carpoolAvenues,
      enabled: _state.currentUser.isVolunteerDriver,
    );
  }

  Future<void> _configureVolunteer() async {
    if (_vehicles.isEmpty) {
      await _addOrEditVehicle();
      if (_vehicles.isEmpty) return;
    }
    final currentLocation =
        await ParkRideLocationService().getCurrentLocationWithAddress();
    if (!mounted) return;
    final address = currentLocation?.address.toLowerCase() ?? '';
    final zone = _avenuesByMunicipality.keys.firstWhere(
      (key) => address.contains(key),
      orElse: () => 'monterrey',
    );
    final candidates = _avenuesByMunicipality[zone]!;
    final selected = _state.currentUser.carpoolAvenues.toSet();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
                'Ruta voluntaria: ${zone == 'monterrey' ? 'Monterrey Centro' : zone}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(currentLocation?.address ?? 'No se pudo obtener ubicación.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: candidates
                  .map((avenue) => FilterChip(
                        label: Text(avenue),
                        selected: selected.contains(avenue),
                        onSelected: (active) => setModalState(() {
                          active
                              ? selected.add(avenue)
                              : selected.remove(avenue);
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                if (selected.length < 2) {
                  _showMessage('Selecciona al menos dos avenidas.',
                      error: true);
                  return;
                }
                Navigator.pop(context);
                await _saveVolunteer(
                  vehicles: _vehicles,
                  avenues: selected.toList(),
                  enabled: true,
                );
                if (mounted) _showMessage('Conductor voluntario activado.');
              },
              icon: const Icon(Icons.volunteer_activism_rounded),
              label: const Text('Activar Conductor Voluntario'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _state.currentUser;
    final greenPoints = (_state.totalCo2SavingsKg * 100).round();
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Agregar vehículo',
            onPressed: _isRouteDriver ? null : _addOrEditVehicle,
          )
        ],
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Card(
            child: ListTile(
              leading:
                  const AppLogo(size: 56, borderRadius: 16, showBorder: true),
              title: Text(user.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${user.correo}\n${user.rol}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFDCFCE7),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                const Icon(Icons.eco_rounded,
                    color: Color(0xFF15803D), size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Gracias por cuidar el planeta!\nHas ahorrado '
                    '${_state.totalCo2SavingsKg.toStringAsFixed(1)} kg de CO2\n'
                    'Has ganado $greenPoints Puntos Verdes',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
          ),
          if (!_isRouteDriver) ...[
            const SizedBox(height: 18),
            Card(
              child: SwitchListTile(
                title: const Text('Modo Conductor Voluntario',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user.isVolunteerDriver
                    ? 'Activo: ${user.carpoolAvenues.join(', ')}'
                    : 'Comparte tu ruta y gana Puntos Verdes.'),
                value: user.isVolunteerDriver,
                onChanged: _saving
                    ? null
                    : (enabled) async {
                        if (enabled) {
                          await _configureVolunteer();
                        } else {
                          await _saveVolunteer(
                            vehicles: _vehicles,
                            avenues: user.carpoolAvenues,
                            enabled: false,
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              const Expanded(
                  child: Text('Mis Vehículos',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold))),
              TextButton.icon(
                  onPressed: _addOrEditVehicle,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar vehículo')),
            ]),
            if (_vehicles.isEmpty)
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aún no registras vehículos.')))
            else
              ..._vehicles.asMap().entries.map((entry) => Card(
                    child: ListTile(
                      title: Text(
                          '${entry.value['brand']} ${entry.value['model']}'),
                      subtitle: Text(
                          '${entry.value['plate']} · ${entry.value['color']}\n${entry.value['insurer']} · Póliza ${entry.value['policy']}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) async {
                          final vehicles = _vehicles;
                          if (action == 'edit') {
                            await _addOrEditVehicle(entry.key);
                          } else {
                            vehicles.removeAt(entry.key);
                            await _saveVolunteer(
                              vehicles: vehicles,
                              avenues: user.carpoolAvenues,
                              enabled: false,
                            );
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Eliminar')),
                        ],
                      ),
                    ),
                  )),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/ReportesESG'),
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Reportar Incidencia'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/ParkrideLogin', (route) => false),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.red)),
          ),
        ]),
      ),
      bottomNavigationBar: _isRouteDriver
          ? const ParkRideBottomNavBar(
              currentIndex: 2, items: ParkRideBottomNavBar.driverItems)
          : const ParkRideBottomNavBar(currentIndex: 3),
    );
  }
}
