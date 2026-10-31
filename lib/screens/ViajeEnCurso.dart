import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/parkride_models.dart';
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
  Timer? _qrTimer;

  @override
  void initState() {
    super.initState();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

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
                            onPressed: trip.isQrExpired
                                ? null
                                : () => _showPassengerQRDialog(context, trip),
                            icon: const Icon(Icons.qr_code_2,
                                color: Color(0xFF22C55E)),
                            label: Text(
                              trip.isQrExpired
                                  ? 'Pase de Abordaje Expirado'
                                  : 'Ver Mi Pase de Abordaje (QR)',
                              style: const TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  void _showPassengerQRDialog(BuildContext context, TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => _BoardingPassDialog(trip: trip),
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

class _BoardingPassDialog extends StatefulWidget {
  final TripModel trip;

  const _BoardingPassDialog({required this.trip});

  @override
  State<_BoardingPassDialog> createState() => _BoardingPassDialogState();
}

class _BoardingPassDialogState extends State<_BoardingPassDialog> {
  late final Timer _timer;
  late int _secondsRemaining;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.trip.qrExpiresAt == null
        ? 900
        : widget.trip.qrTimeRemaining.inSeconds.clamp(0, 900).toInt();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _secondsRemaining <= 0) {
        _timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = _secondsRemaining == 0;
    final remaining = Duration(seconds: _secondsRemaining);
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            color: expired ? const Color(0xFF64748B) : const Color(0xFF22C55E),
            size: 28,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pase de Abordaje',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: expired
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : const ColorFilter.mode(
                    Colors.transparent, BlendMode.multiply),
            child: QrImageView(
              data: widget.trip.qrCode,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            expired ? 'EXPIRADO' : '$minutes:$seconds',
            style: TextStyle(
              color:
                  expired ? const Color(0xFF64748B) : const Color(0xFF16A34A),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            expired
                ? 'Este pase ya no es válido. Solicita un nuevo viaje.'
                : 'Muestra este código al chofer para registrar tu abordaje.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
