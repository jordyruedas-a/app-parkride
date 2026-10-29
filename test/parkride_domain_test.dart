import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkride/core/constants/parkride_constants.dart';
import 'package:parkride/models/user_profile.dart';
import 'package:parkride/services/airport_route_service.dart';

void main() {
  test('ParkRide should expose the three allowed transport options', () {
    expect(ParkRideConstants.allowedTransportTypes, hasLength(3));
    expect(ParkRideConstants.allowedTransportTypes, contains('shuttle'));
    expect(ParkRideConstants.allowedTransportTypes, contains('van'));
    expect(ParkRideConstants.allowedTransportTypes, contains('carpool'));
  });

  test('seed user profiles should be available for the required roles', () {
    final users = ParkRideSeedData.seedUsers();
    expect(users.map((u) => u.role), containsAll(['passenger', 'driver', 'admin']));
  });

  test('profile DTO should keep corporate optional fields nullable', () {
    final profile = UserProfile(
      id: 'u-100',
      email: 'user@parkride.com',
      name: 'Ana Gómez',
      role: 'passenger',
      company: 'ParkRide',
      phone: '5551234567',
    );

    expect(profile.company, 'ParkRide');
    expect(profile.department, isNull);
    expect(profile.employeeNumber, isNull);
  });

  test('nearest route recommendation should stay on real industrial corridors', () {
    final recommendation = AirportRouteService.recommendNearestRoute(const LatLng(25.6790, -100.4400));

    expect(recommendation.route.routeName, isNotEmpty);
    expect(recommendation.distanceKm, lessThan(8.0));
    expect(recommendation.route.stops.any((stop) => stop.zona.contains('Santa Catarina')), isTrue);
  });
}
