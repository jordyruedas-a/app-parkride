import 'package:flutter/material.dart';

import '../services/parkride_business_rules.dart';
import '../services/parkride_state.dart';
import '../widgets/bottom_nav_bar.dart';

class ReportesESGScreen extends StatefulWidget {
  const ReportesESGScreen({super.key});

  @override
  State<ReportesESGScreen> createState() => _ReportesESGScreenState();
}

class _ReportesESGScreenState extends State<ReportesESGScreen> {
  final _state = ParkRideState();
  final _commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  String? _selectedCategory;
  bool _sending = false;

  bool get _isDriver =>
      ParkRideBusinessRules.isDriverRole(_state.currentUser.rol);

  List<String> get _categories => _isDriver
      ? const [
          'Falla mecánica',
          'Usuario no se presentó',
          'Tráfico pesado',
          'Maltrato de usuario',
          'Otro',
        ]
      : const [
          'Maltrato de chofer',
          'Unidad en mal estado',
          'Retraso de unidad',
          'Otro',
        ];

  @override
  void initState() {
    super.initState();
    _reportsFuture = _state.getReports();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _selectedCategory;
    final comment = _commentController.text.trim();
    if (category == null || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona una incidencia y describe lo ocurrido.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await _state.submitReport(category: category, comment: comment);
      if (!mounted) return;
      _commentController.clear();
      setState(() {
        _selectedCategory = null;
        _reportsFuture = _state.getReports();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado al supervisor.'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el reporte: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverNavigation = _isDriver;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Reportar incidencia')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Qué ocurrió?',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tu reporte se registra con fecha y será atendido por el supervisor.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                    selectedColor: const Color(0xFFDCFCE7),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? const Color(0xFF166534)
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                minLines: 2,
                maxLines: 3,
                maxLength: 5000,
                decoration: InputDecoration(
                  labelText: _selectedCategory == 'Otro'
                      ? 'Describe la incidencia'
                      : 'Comentarios adicionales',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(_sending ? 'Enviando...' : 'Enviar reporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Mis reportes',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text(
                      'No fue posible cargar los reportes.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    );
                  }
                  final reports = snapshot.data ?? const [];
                  if (reports.isEmpty) {
                    return const Text(
                      'Aún no has enviado incidencias.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    );
                  }
                  return Column(
                    children: reports.map((report) {
                      final resolved = report['status'] == 'resolved';
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    report['category']?.toString() ??
                                        'Incidencia',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  resolved ? 'Resuelto' : 'Pendiente',
                                  style: TextStyle(
                                    color: resolved
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(report['comment']?.toString() ?? ''),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ParkRideBottomNavBar(
        currentIndex: driverNavigation ? 2 : 3,
        items: driverNavigation ? ParkRideBottomNavBar.driverItems : null,
      ),
    );
  }
}
