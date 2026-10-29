import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/parkride_models.dart';

class AirportRoute {
  final String id;
  final String routeName;
  final String destinationName;
  final String description;
  final List<LocationNode> stops;
  final List<LatLng> routePoints;
  final String schedule;

  const AirportRoute({
    required this.id,
    required this.routeName,
    required this.destinationName,
    required this.description,
    required this.stops,
    this.routePoints = const [],
    this.schedule = '6:30, 7:00, 7:30, 8:00, 17:30, 18:00, 18:30',
  });

  String get name => routeName;
  String get scheduleInfo => schedule;
  LatLng get start =>
      routePoints.isNotEmpty ? routePoints.first : stops.first.latLng;
  LatLng get end =>
      routePoints.isNotEmpty ? routePoints.last : stops.last.latLng;
}

class RouteMatch {
  final AirportRoute route;
  final double distanceKm;

  const RouteMatch({
    required this.route,
    required this.distanceKm,
  });

  String get routeName => route.routeName;
  String get destinationName => route.destinationName;
}

/// Servicio de rutas realistas para Monterrey, enfocadas en la conexión con el aeropuerto
/// y evitando recorridos no realistas por zonas residenciales, montes o parques.
class AirportRouteService {
  static final List<LocationNode> fixedRouteStops = [
    LocationNode(
      id: 'SC1',
      nombre: 'Santa Catarina - Av. Fundadores',
      zona: 'Santa Catarina',
      iconType: 'place',
      latitude: 25.6844,
      longitude: -100.4366,
    ),
    LocationNode(
      id: 'MTY1',
      nombre: 'Centro Monterrey - Av. Gonzalitos',
      zona: 'Monterrey',
      iconType: 'bus_station',
      latitude: 25.6845,
      longitude: -100.3218,
    ),
    LocationNode(
      id: 'MTY2',
      nombre: 'Av. Constitución - Centro',
      zona: 'Monterrey',
      iconType: 'place',
      latitude: 25.6691,
      longitude: -100.3182,
    ),
    LocationNode(
      id: 'AP1',
      nombre: 'Apodaca - Av. Sendero',
      zona: 'Apodaca',
      iconType: 'place',
      latitude: 25.7661,
      longitude: -100.1994,
    ),
    LocationNode(
      id: 'AER1',
      nombre: 'Terminal A - Aeropuerto MTY',
      zona: 'Aeropuerto',
      iconType: 'flight',
      latitude: 25.7782,
      longitude: -100.1067,
    ),
    LocationNode(
      id: 'AER2',
      nombre: 'Terminal B - Aeropuerto MTY',
      zona: 'Aeropuerto',
      iconType: 'airport',
      latitude: 25.7766,
      longitude: -100.1140,
    ),
  ];

  static final List<AirportRoute> fixedRoutes = [
    AirportRoute(
      id: 'AER-NORTE',
      routeName: 'Ruta Aeropuerto Norte',
      destinationName: 'Aeropuerto MTY',
      description: 'Santa Catarina → Av. Gonzalitos → Aeropuerto',
      schedule: '5:40, 6:30, 7:30, 8:45, 17:00, 18:15',
      stops: [
        fixedRouteStops[0],
        fixedRouteStops[1],
        fixedRouteStops[2],
        fixedRouteStops[3],
        fixedRouteStops[4]
      ],
      routePoints: [
        const LatLng(25.6844, -100.4366),
        const LatLng(25.6846, -100.4200),
        const LatLng(25.6848, -100.3750),
        const LatLng(25.6852, -100.3218),
        const LatLng(25.6890, -100.2600),
        const LatLng(25.7260, -100.2200),
        const LatLng(25.7661, -100.1994),
        const LatLng(25.7782, -100.1067),
      ],
    ),
    AirportRoute(
      id: 'AER-CENTRO',
      routeName: 'Ruta Aeropuerto Centro',
      destinationName: 'Aeropuerto MTY',
      description: 'Centro Monterrey → Av. Constitución → Aeropuerto',
      schedule: '6:00, 7:00, 8:15, 9:00, 17:15, 18:30',
      stops: [
        fixedRouteStops[1],
        fixedRouteStops[2],
        fixedRouteStops[3],
        fixedRouteStops[4]
      ],
      routePoints: [
        const LatLng(25.6845, -100.3218),
        const LatLng(25.6782, -100.3183),
        const LatLng(25.6719, -100.3172),
        const LatLng(25.7200, -100.2450),
        const LatLng(25.7661, -100.1994),
        const LatLng(25.7782, -100.1067),
      ],
    ),
    AirportRoute(
      id: 'AER-SUR',
      routeName: 'Ruta Aeropuerto Sur',
      destinationName: 'Aeropuerto MTY',
      description: 'San Jerónimo → Av. Universidad → Aeropuerto',
      schedule: '5:50, 6:45, 8:00, 16:45, 18:00',
      stops: [
        fixedRouteStops[0],
        fixedRouteStops[3],
        fixedRouteStops[4],
        fixedRouteStops[5]
      ],
      routePoints: [
        const LatLng(25.6844, -100.4366),
        const LatLng(25.7020, -100.4000),
        const LatLng(25.7450, -100.3000),
        const LatLng(25.7661, -100.1994),
        const LatLng(25.7766, -100.1140),
      ],
    ),
  ];

  static final List<AirportRoute> customRoutes = <AirportRoute>[];

  static List<AirportRoute> get allRoutes =>
      <AirportRoute>[...fixedRoutes, ...customRoutes];

  static void addCustomRoute(AirportRoute route) {
    customRoutes.add(route);
  }

  static RouteMatch recommendNearestRoute(LatLng userPosition) =>
      findNearestRoute(userPosition);

  static String buildRouteRecommendationText(LatLng userPosition) {
    final recommendation = recommendNearestRoute(userPosition);
    final distanceText = recommendation.distanceKm < 1
        ? '${(recommendation.distanceKm * 1000).round()} m'
        : '${recommendation.distanceKm.toStringAsFixed(1)} km';
    return 'Tu ruta más cercana es ${recommendation.route.routeName} a ${distanceText} del punto actual.';
  }

  static RouteMatch findNearestRoute(LatLng userPosition) {
    double minimal = double.infinity;
    AirportRoute best = allRoutes.first;

    for (final route in allRoutes) {
      for (final stop in route.stops) {
        final distance = _distanceKm(userPosition, stop.latLng);
        if (distance < minimal) {
          minimal = distance;
          best = route;
        }
      }
    }

    return RouteMatch(route: best, distanceKm: minimal);
  }

  static List<RouteMatch> findNearestRoutes(LatLng userPosition,
      {int maxResults = 3}) {
    final matches = <RouteMatch>[];

    for (final route in allRoutes) {
      double minDist = double.infinity;
      for (final stop in route.stops) {
        final dist = _distanceKm(userPosition, stop.latLng);
        if (dist < minDist) minDist = dist;
      }
      matches.add(RouteMatch(route: route, distanceKm: minDist));
    }

    matches.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return matches.take(maxResults).toList();
  }

  static double _distanceKm(LatLng start, LatLng end) {
    const earthRadiusKm = 6371.0;
    final lat1 = start.latitude * (math.pi / 180);
    final lat2 = end.latitude * (math.pi / 180);
    final deltaLat = (end.latitude - start.latitude) * (math.pi / 180);
    final deltaLng = (end.longitude - start.longitude) * (math.pi / 180);

    final a = (math.sin(deltaLat / 2) * math.sin(deltaLat / 2)) +
        (math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2));

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
