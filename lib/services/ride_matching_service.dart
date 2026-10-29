import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/parkride_models.dart';

class DriverCandidate {
  final String id;
  final String nombre;
  final String vehicleInfo;
  final int capacidadPasajeros;
  final bool isOnline;
  final LatLng position;

  DriverCandidate({
    required this.id,
    required this.nombre,
    required this.vehicleInfo,
    required this.capacidadPasajeros,
    required this.isOnline,
    required this.position,
  });
}

class MatchingResult {
  final bool matched;
  final int score;
  final String status;
  final String driverName;
  final String vehicleInfo;
  final DriverCandidate? driver;

  MatchingResult({
    required this.matched,
    required this.score,
    required this.status,
    required this.driverName,
    required this.vehicleInfo,
    this.driver,
  });
}

class _DriverScore {
  final DriverCandidate driver;
  final int score;

  _DriverScore({required this.driver, required this.score});
}

class RideMatchingService {
  static MatchingResult findBestMatch({
    required LocationNode passengerOrigin,
    required LocationNode passengerDestination,
    required int requestedPassengers,
    required List<DriverCandidate> drivers,
  }) {
    final eligible = drivers.where((driver) {
      return driver.isOnline &&
          driver.capacidadPasajeros >= requestedPassengers;
    }).toList();

    if (eligible.isEmpty) {
      return MatchingResult(
        matched: false,
        score: 0,
        status: 'Sin chofer disponible para $requestedPassengers pasajero(s)',
        driverName: 'Ninguno',
        vehicleInfo: 'Sin vehículo disponible',
      );
    }

    final scored = eligible.map((driver) {
      final proximityToOrigin =
          _haversineKm(driver.position, passengerOrigin.latLng);
      final proximityToDestination =
          _haversineKm(driver.position, passengerDestination.latLng);

      final baseScore = (100 - (proximityToOrigin * 12.0)).clamp(0.0, 100.0);
      final destinationBonus =
          (100 - (proximityToDestination * 14.0)).clamp(0.0, 30.0);
      final capacityBonus =
          ((driver.capacidadPasajeros - requestedPassengers) * 10.0)
              .clamp(0.0, 25.0);
      final score =
          (baseScore + destinationBonus + capacityBonus + 15.0).round();

      return _DriverScore(driver: driver, score: score.clamp(0, 100));
    }).toList();

    final best = scored.reduce((bestCurrent, candidate) {
      return candidate.score > bestCurrent.score ? candidate : bestCurrent;
    });

    if (best.score < 55) {
      return MatchingResult(
        matched: false,
        score: best.score,
        status: 'Sin chofer disponible con un match aceptable',
        driverName: best.driver.nombre,
        vehicleInfo: best.driver.vehicleInfo,
      );
    }

    return MatchingResult(
      matched: true,
      score: best.score,
      status: 'Asignado a ${best.driver.nombre} • match ${best.score}/100',
      driverName: best.driver.nombre,
      vehicleInfo: best.driver.vehicleInfo,
      driver: best.driver,
    );
  }

  static double _haversineKm(LatLng start, LatLng end) {
    const earthRadiusKm = 6371.0;
    final lat1 = start.latitude * (3.141592653589793 / 180);
    final lat2 = end.latitude * (3.141592653589793 / 180);
    final deltaLat =
        (end.latitude - start.latitude) * (3.141592653589793 / 180);
    final deltaLng =
        (end.longitude - start.longitude) * (3.141592653589793 / 180);

    final a = (math.sin(deltaLat / 2) * math.sin(deltaLat / 2)) +
        (math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2));

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
