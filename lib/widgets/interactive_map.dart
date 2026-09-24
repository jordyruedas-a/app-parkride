import 'package:flutter/material.dart';
import '../models/parkride_models.dart';

class IndustrialMapCanvas extends StatelessWidget {
  final String? selectedOrigen;
  final String? selectedDestino;
  final Function(LocationNode)? onNodeSelected;
  final bool isMiniMap;

  const IndustrialMapCanvas({
    super.key,
    this.selectedOrigen,
    this.selectedDestino,
    this.onNodeSelected,
    this.isMiniMap = false,
  });

  @override
  Widget build(BuildContext context) {
    final nodes = [
      LocationNode(id: 'NODE_01', nombre: 'Nave A', zona: 'Zona Norte', xRatio: 0.20, yRatio: 0.25, iconType: 'factory'),
      LocationNode(id: 'NODE_02', nombre: 'Nave B', zona: 'Zona Norte', xRatio: 0.50, yRatio: 0.20, iconType: 'factory'),
      LocationNode(id: 'NODE_03', nombre: 'Nave C', zona: 'Zona Este', xRatio: 0.80, yRatio: 0.25, iconType: 'factory'),
      LocationNode(id: 'NODE_07', nombre: 'Comedor B', zona: 'Zona Central', xRatio: 0.50, yRatio: 0.45, iconType: 'restaurant'),
      LocationNode(id: 'NODE_08', nombre: 'Administración A', zona: 'Zona Central', xRatio: 0.25, yRatio: 0.45, iconType: 'business'),
      LocationNode(id: 'NODE_09', nombre: 'Administración B', zona: 'Zona Central', xRatio: 0.75, yRatio: 0.45, iconType: 'business'),
      LocationNode(id: 'NODE_10', nombre: 'Bodega A', zona: 'Zona Sur', xRatio: 0.25, yRatio: 0.75, iconType: 'warehouse'),
      LocationNode(id: 'NODE_11', nombre: 'Bodega C', zona: 'Zona Sur', xRatio: 0.75, yRatio: 0.75, iconType: 'warehouse'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(isMiniMap ? 16 : 20),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Grid Background Lines
              CustomPaint(
                size: Size(width, height),
                painter: MapGridPainter(),
              ),

              // Road Connection Lines
              CustomPaint(
                size: Size(width, height),
                painter: MapRoadsPainter(nodes: nodes, width: width, height: height),
              ),

              // Location Nodes
              ...nodes.map((node) {
                final x = node.xRatio * width;
                final y = node.yRatio * height;
                final isOrigen = node.nombre == selectedOrigen;
                final isDestino = node.nombre == selectedDestino;

                Color nodeColor = const Color(0xFF475569);
                if (isOrigen) nodeColor = const Color(0xFF3B82F6);
                if (isDestino) nodeColor = const Color(0xFF22C55E);

                return Positioned(
                  left: x - (isMiniMap ? 28 : 36),
                  top: y - (isMiniMap ? 20 : 26),
                  child: GestureDetector(
                    onTap: () {
                      if (onNodeSelected != null) {
                        onNodeSelected!(node);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMiniMap ? 6 : 10,
                            vertical: isMiniMap ? 3 : 5,
                          ),
                          decoration: BoxDecoration(
                            color: isOrigen || isDestino ? nodeColor : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOrigen || isDestino ? Colors.white : const Color(0xFF64748B),
                              width: isOrigen || isDestino ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isOrigen || isDestino)
                                BoxShadow(
                                  color: nodeColor.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOrigen ? Icons.my_location : (isDestino ? Icons.location_on : Icons.domain),
                                color: Colors.white,
                                size: isMiniMap ? 12 : 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                node.nombre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMiniMap ? 10 : 12,
                                  fontWeight: isOrigen || isDestino ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Active Vehicle Marker
              Positioned(
                left: 0.48 * width - 16,
                top: 0.32 * height - 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEAB308).withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.electric_car, color: Colors.black, size: 18),
                ),
              ),

              // Legend overlay
              Positioned(
                bottom: 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text("Nodos Activos", style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapRoadsPainter extends CustomPainter {
  final List<LocationNode> nodes;
  final double width;
  final double height;

  MapRoadsPainter({required this.nodes, required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < nodes.length - 1; i++) {
      final start = Offset(nodes[i].xRatio * width, nodes[i].yRatio * height);
      final end = Offset(nodes[i + 1].xRatio * width, nodes[i + 1].yRatio * height);
      canvas.drawLine(start, end, paint);
    }

    if (nodes.length > 3) {
      final start = Offset(nodes[0].xRatio * width, nodes[0].yRatio * height);
      final end = Offset(nodes[3].xRatio * width, nodes[3].yRatio * height);
      canvas.drawLine(start, end, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
