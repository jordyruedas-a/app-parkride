import 'dart:math' as math;

import 'package:flutter/material.dart';

class CarpoolRadarWidget extends StatefulWidget {
  final int pendingRequests;
  final VoidCallback onOpenRequests;
  final VoidCallback onDisconnect;

  const CarpoolRadarWidget({
    super.key,
    required this.pendingRequests,
    required this.onOpenRequests,
    required this.onDisconnect,
  });

  @override
  State<CarpoolRadarWidget> createState() => _CarpoolRadarWidgetState();
}

class _CarpoolRadarWidgetState extends State<CarpoolRadarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: 92,
          width: 92,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _RadarPainter(_controller.value),
              child: const Center(
                  child: Icon(Icons.radar_rounded,
                      color: Color(0xFF86EFAC), size: 32)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Modo Chófer Activado - Buscando pasajeros cercanos...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        if (widget.pendingRequests > 0) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: widget.onOpenRequests,
            icon: const Icon(Icons.person_pin_circle_rounded),
            label: Text('${widget.pendingRequests} solicitud(es) pendiente(s)'),
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: widget.onDisconnect,
          icon: const Icon(Icons.power_settings_new),
          label: const Text('Desconectar'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
        ),
      ]),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  const _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()..style = PaintingStyle.stroke;
    for (final factor in [0.35, 0.65, 1.0]) {
      paint
        ..color = const Color(0xFF4ADE80).withValues(alpha: 1 - factor * .65)
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius * factor, paint);
    }
    paint
      ..color = const Color(0xFF86EFAC)
      ..strokeWidth = 2;
    canvas.drawLine(
        center,
        center +
            Offset(math.cos(progress * math.pi * 2),
                    math.sin(progress * math.pi * 2)) *
                radius,
        paint);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
