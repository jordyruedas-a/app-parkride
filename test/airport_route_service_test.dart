import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkride/services/airport_route_service.dart';

void main() {
  group('AirportRouteService', () {
    test('genera exactamente 9 rutas con destinos metropolitanos y aeropuerto', () {
      expect(AirportRouteService.fixedRoutes.length, 9);
      for (final route in AirportRouteService.fixedRoutes) {
        expect(route.stops.isNotEmpty, isTrue);
      }
    });

    test('devuelve la ruta más cercana al usuario actual', () {
      final nearest = AirportRouteService.findNearestRoute(
        const LatLng(25.6877, -100.3161),
      );

      expect(nearest.routeName, isNotEmpty);
      expect(nearest.distanceKm, greaterThanOrEqualTo(0));
      expect(nearest.distanceKm, lessThan(50));
    });
  });
}
