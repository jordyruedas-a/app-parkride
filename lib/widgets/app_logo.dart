import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showBorder;

  const AppLogo({
    super.key,
    this.size = 64.0,
    this.borderRadius = 16.0,
    this.showBorder = false,
  });

  static const String logoUrl = "https://i.ibb.co/RkwS7Xjn/Imagen-2-jpg.jpg";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Safe fallback if network connection is offline
            return Container(
              color: const Color(0xFF22C55E),
              child: Icon(Icons.directions_car_filled,
                  color: Colors.white, size: size * 0.5),
            );
          },
        ),
      ),
    );
  }
}
