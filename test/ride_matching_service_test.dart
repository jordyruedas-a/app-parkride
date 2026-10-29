import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkride/models/parkride_models.dart';
import 'package:parkride/services/ride_matching_service.dart';

void main() {
  group('RideMatchingService', () {
    test('encuentra un chofer cercano con capacidad disponible', () {
      final passengers = [
        LocationNode(
          id: 'P1',
          nombre: 'Nave A',
          zona: 'FIME',
          iconType: 'factory',
          latitude: 25.7252,
          longitude: -100.3131,
        ),
        LocationNode(
          id: 'P2',
          nombre: 'Nave B',
          zona: 'FIME',
          iconType: 'warehouse',
          latitude: 25.7258,
          longitude: -100.3155,
        ),
      ];

      final drivers = [
        DriverCandidate(
          id: 'D1',
          nombre: 'Juan Pérez Ochoa',
          vehicleInfo: 'Tigre-Van Eléctrica #01',
          capacidadPasajeros: 4,
          isOnline: true,
          position: const LatLng(25.7256, -100.3128),
        ),
        DriverCandidate(
          id: 'D2',
          nombre: 'Carlos Garza',
          vehicleInfo: 'Shuttle #02',
          capacidadPasajeros: 2,
          isOnline: true,
          position: const LatLng(25.7300, -100.3200),
        ),
      ];

      final result = RideMatchingService.findBestMatch(
        passengerOrigin: passengers.first,
        passengerDestination: passengers.last,
        requestedPassengers: 2,
        drivers: drivers,
      );

      expect(result.matched, isTrue);
      expect(result.driverName, 'Juan Pérez Ochoa');
      expect(result.score, greaterThan(70));
      expect(result.status, contains('Asignado'));
    });

    test('rechaza a un chofer si supera la capacidad solicitada', () {
      final drivers = [
        DriverCandidate(
          id: 'D3',
          nombre: 'Ana López',
          vehicleInfo: 'Carrito #03',
          capacidadPasajeros: 1,
          isOnline: true,
          position: const LatLng(25.7252, -100.3131),
        ),
      ];

      final result = RideMatchingService.findBestMatch(
        passengerOrigin: LocationNode(
          id: 'P1',
          nombre: 'Puerta Principal',
          zona: 'Acceso',
          iconType: 'meeting_room',
          latitude: 25.7240,
          longitude: -100.3170,
        ),
        passengerDestination: LocationNode(
          id: 'P2',
          nombre: 'Nave B',
          zona: 'Almacén',
          iconType: 'warehouse',
          latitude: 25.7258,
          longitude: -100.3155,
        ),
        requestedPassengers: 2,
        drivers: drivers,
      );

      expect(result.matched, isFalse);
      expect(result.status, contains('Sin chofer disponible'));
    });
  });
}
