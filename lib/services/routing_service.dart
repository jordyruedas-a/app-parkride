import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _osrmBaseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  static Future<List<LatLng>> getRoutePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      '$_osrmBaseUrl/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('OSRM respondió con status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final routes = decoded['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        throw Exception('OSRM no devolvió ninguna ruta');
      }

      final encoded = routes.first['geometry'];
      if (encoded is! String || encoded.isEmpty) {
        throw Exception('La ruta no tiene geometría válida');
      }

      final points = decodePolyline(encoded, accuracyExponent: 5);

      if (points.isEmpty) {
        throw Exception('La geometría decodificada está vacía');
      }

      return points
          .map((point) => LatLng(
                (point[0] as num).toDouble(),
                (point[1] as num).toDouble(),
              ))
          .toList();
    } catch (e) {
      debugPrint('[RoutingService] Error calculando ruta con OSRM: $e');
      return <LatLng>[];
    }
  }

  static Future<List<LatLng>> getRouteForStops(List<LatLng> stops) async {
    if (stops.length < 2) {
      return <LatLng>[];
    }

    final points = <LatLng>[];
    for (var index = 0; index < stops.length - 1; index++) {
      final segment = await getRoutePoints(stops[index], stops[index + 1]);
      if (segment.isEmpty) {
        return <LatLng>[];
      }
      points.addAll(points.isEmpty ? segment : segment.skip(1));
    }
    return points;
  }
}
