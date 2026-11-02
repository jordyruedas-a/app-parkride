import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parkride_models.dart';
import 'airport_route_service.dart';
import 'location_service.dart';
import 'parkride_business_rules.dart';
import 'parkride_api_service.dart';
import 'ride_matching_service.dart';
import 'supabase_service.dart';

class ParkRideState extends ChangeNotifier {
  static final ParkRideState _instance = ParkRideState._internal();
  factory ParkRideState() => _instance;
  ParkRideState._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final ParkRideApiService _apiService = ParkRideApiService.instance;

  // Coordenadas del parque industrial principal (Monterrey, NL)
  static const LatLng campusCenter = LatLng(25.7252, -100.3131);

  UserModel currentUser = UserModel(
    idEmpleado: 'USR-0001',
    nombre: 'Usuario ParkRide',
    correo: 'usuario@empresa.com',
    departamento: 'Movilidad Corporativa',
    empresa: 'ParkRide',
    telefono: '+52 81 0000 0000',
    turno: 'Turno Matutino',
    saldoCreditos: 450,
    rol: 'Pasajero',
    hasVehicle: false,
    vehicleInfo: null,
  );

  // Stats
  double totalCo2SavingsKg = 0.0;

  UserModel currentDriver = UserModel(
    idEmpleado: 'CON-10942',
    nombre: 'Chofer ParkRide',
    correo: 'conductor@empresa.com',
    departamento: 'Operación de Transporte',
    empresa: 'ParkRide',
    telefono: '+52 81 9876 5432',
    turno: 'Turno Matutino',
    saldoCreditos: 680,
    rol: 'Chofer',
    hasVehicle: true,
    vehicleInfo: 'Toyota Corolla 2024 • ABC-1234',
  );

  bool isDriverOnline = true;
  String driverStatus =
      "Disponible"; // "Disponible", "En camino a origen", "En viaje", "Desconectado"
  LatLng userCurrentLocation = campusCenter;

  List<AirportRoute> get airportRoutes => AirportRouteService.fixedRoutes;

  // The backend returns one assigned route for each route driver. The local
  // fallback keeps the same one-route-only contract while offline.
  AirportRoute get assignedDriverRoute => airportRoutes.first;
  String? nextRouteDeparture = '07:30';
  String? _activeRouteId;
  List<ParkRideRoute> routes = const [];

  RouteMatch? closestAirportRoute;

  final List<LocationNode> nodes = AirportRouteService.fixedRouteStops;

  // Opciones de transporte: Solo Camión, Van y Carpooling
  final List<TransportOption> availableOptions = [
    TransportOption(
      id: 'OPT_01',
      title: 'Camión',
      type: 'Transporte colectivo',
      costCredits: 5,
      etaMinutes: 8,
      co2SavingsKg: 1.2,
      iconName: 'directions_bus',
    ),
    TransportOption(
      id: 'OPT_02',
      title: 'Van Empresarial',
      type: 'Van corporativa',
      costCredits: 10,
      etaMinutes: 5,
      co2SavingsKg: 0.9,
      iconName: 'airport_shuttle',
    ),
    TransportOption(
      id: 'OPT_03',
      title: 'Carpooling',
      type: 'Compañeros de trabajo',
      costCredits: 3,
      etaMinutes: 12,
      co2SavingsKg: 0.6,
      iconName: 'people',
    ),
  ];

  // Active Trip
  TripModel? currentTrip;
  bool isSearchingTrip = false;

  // Trip history (empty by default - clean DB)
  List<TripModel> tripHistory = [];

  List<DriverCandidate> get availableDrivers {
    return [
      DriverCandidate(
        id: currentDriver.idEmpleado,
        nombre: currentDriver.nombre,
        vehicleInfo: currentDriver.vehicleInfo ?? 'Van de Transporte #01',
        capacidadPasajeros: 8,
        isOnline: isDriverOnline,
        position: const LatLng(25.7255, -100.3125),
      ),
    ];
  }

  LocationNode getNearestNode(LatLng point, {LocationNode? exclude}) {
    if (nodes.isEmpty) {
      throw StateError(
          'No hay nodos disponibles para calcular la ubicación cercana.');
    }

    LocationNode nearest = nodes.first;
    double bestDistance = double.infinity;

    for (final node in nodes) {
      if (exclude != null && node.id == exclude.id) {
        continue;
      }
      final distance = _roughDistanceKm(point, node.latLng);
      if (distance < bestDistance) {
        bestDistance = distance;
        nearest = node;
      }
    }

    return nearest;
  }

  double calculateNodeProximity(LocationNode origin, LocationNode destination) {
    final distance = (origin.latitude - destination.latitude).abs() +
        (origin.longitude - destination.longitude).abs();
    return (1 / (distance + 0.0001)).clamp(0.0, 1.0);
  }

  static double _roughDistanceKm(LatLng from, LatLng to) {
    final latDiff = (from.latitude - to.latitude).abs();
    final lngDiff = (from.longitude - to.longitude).abs();
    return (latDiff * latDiff + lngDiff * lngDiff) * 111.0;
  }

  bool capacityFilterAllowsRequest(int requestedPassengers, int capacity) {
    return requestedPassengers <= capacity;
  }

  // Driver Incoming Request
  TripModel? incomingDriverRequest;

  static String normalizeRole(String? role) =>
      ParkRideBusinessRules.normalizeRole(role);

  // Métodos de autenticación integrados con Supabase
  Future<void> loginUser(String email, String password) async {
    final apiUser = await _apiService.login(email, password);
    final user = _userFromApi(apiUser);
    final normalizedRole = normalizeRole(user.rol);
    currentUser = user.copyWith(rol: normalizedRole);
    if (normalizedRole.contains('Ruta') || normalizedRole.contains('Chofer')) {
      currentDriver = currentUser;
    }
    await _loadRoutes();
    notifyListeners();
  }

  Future<void> activateVolunteerRoute({
    required List<String> avenues,
    required String destination,
    required List<LatLng> route,
  }) async {
    final response =
        await _apiService.updateCurrentUser(currentUser.idEmpleado, {
      'is_volunteer_driver': true,
      'is_available_for_carpooling': true,
      'volunteer_status': 'searching_passengers',
      'carpool_avenues': avenues,
      'carpool_destination': destination,
      'carpool_route': route
          .map((point) =>
              {'latitude': point.latitude, 'longitude': point.longitude})
          .toList(),
    });
    final updated = _userFromApi(response);
    currentUser = updated.copyWith(rol: normalizeRole(updated.rol));
    notifyListeners();
  }

  Future<void> deactivateVolunteerRoute() async {
    final response =
        await _apiService.updateCurrentUser(currentUser.idEmpleado, {
      'is_available_for_carpooling': false,
      'volunteer_status': 'offline',
    });
    final updated = _userFromApi(response);
    currentUser = updated.copyWith(rol: normalizeRole(updated.rol));
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getCarpoolRequests() =>
      _apiService.getCarpoolRequests();

  Future<void> decideCarpoolRequest(String requestId, bool accept) =>
      _apiService.decideCarpoolRequest(requestId, accept);

  Future<List<Map<String, dynamic>>> getAvailableVolunteers() =>
      _apiService.getAvailableVolunteers();

  Future<void> requestCarpool({
    required String volunteerId,
    required String origin,
  }) =>
      _apiService.requestCarpool(volunteerId: volunteerId, origin: origin);

  Future<void> registerUser({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String empresa = 'ParkRide',
    String telefono = '+52 81 0000 0000',
    String departamento = 'Sin departamento',
    String numEmpleado = '',
    String? vehicleInfo,
  }) async {
    final normalizedRol = normalizeRole(rol);
    await _apiService.register({
      'email': email,
      'password': password,
      'name': nombre,
      'role': _apiRoleFor(normalizedRol),
      'company': empresa,
      'department': departamento,
      'phone': telefono,
      'employee_number': numEmpleado,
    });
    final apiUser = await _apiService.login(email, password);
    currentUser = _userFromApi(apiUser).copyWith(rol: normalizedRol);
    if (normalizedRol.contains('Ruta') || normalizedRol.contains('Chofer')) {
      currentDriver = currentUser;
    }
    await _loadRoutes();
    notifyListeners();
  }

  void logout() {
    _apiService.logout();
    currentUser = UserModel(
      idEmpleado: 'USR-0001',
      nombre: 'Usuario ParkRide',
      correo: 'usuario@empresa.com',
      departamento: 'Movilidad Corporativa',
      empresa: 'ParkRide',
      telefono: '+52 81 0000 0000',
      turno: 'Turno Matutino',
      saldoCreditos: 450,
      rol: 'Pasajero',
    );
    tripHistory = [];
    currentTrip = null;
    incomingDriverRequest = null;
    _activeRouteId = null;
    notifyListeners();
  }

  // Solicitud de viaje por nombres o por nodos
  Future<void> createTripRequest({
    required String origen,
    required String destino,
    required TransportOption option,
  }) async {
    LocationNode origenNode;
    LocationNode destinoNode;
    try {
      origenNode = nodes.firstWhere((n) =>
          n.nombre == origen ||
          n.nombre.toLowerCase().contains(origen.toLowerCase()));
    } catch (_) {
      origenNode = nodes.first;
    }
    try {
      destinoNode = nodes.firstWhere((n) =>
          n.nombre == destino ||
          n.nombre.toLowerCase().contains(destino.toLowerCase()));
    } catch (_) {
      destinoNode = nodes.length > 1 ? nodes[1] : nodes.first;
    }
    await requestTrip(origen: origenNode, destino: destinoNode, option: option);
  }

  Future<void> refreshNearestRoute() async {
    final position = await ParkRideLocationService().getCurrentPosition();
    if (position == null) {
      closestAirportRoute = RouteMatch(
        route: AirportRouteService.fixedRoutes.first,
        distanceKm: 0,
      );
      notifyListeners();
      return;
    }

    userCurrentLocation = position;
    closestAirportRoute = AirportRouteService.findNearestRoute(
      LatLng(position.latitude, position.longitude),
    );
    notifyListeners();
  }

  Future<void> requestTrip({
    required LocationNode origen,
    required LocationNode destino,
    required TransportOption option,
  }) async {
    isSearchingTrip = true;
    notifyListeners();

    final match = RideMatchingService.findBestMatch(
      passengerOrigin: origen,
      passengerDestination: destino,
      requestedPassengers: 1,
      drivers: availableDrivers,
    );

    final assignedDriverName = match.driverName;
    final assignedVehicleInfo = match.vehicleInfo;

    if (_activeRouteId == null) {
      await _loadRoutes();
    }
    if (_activeRouteId == null) {
      isSearchingTrip = false;
      notifyListeners();
      throw StateError('No hay una ruta activa disponible para este viaje.');
    }

    final route = _routeForOption(option);
    if (route == null) {
      isSearchingTrip = false;
      notifyListeners();
      throw StateError('No hay unidades disponibles para ${option.title}.');
    }

    final ticket = await _apiService.createTrip(
      routeId: route.id,
      transportType: _apiTransportType(option),
      origin: origen.nombre,
      destination: destino.nombre,
      creditCost: option.costCredits,
      vehicleType: option.id == 'OPT_02' ? 'van' : 'camion',
    );
    final newTrip = TripModel(
      idViaje: ticket.tripId,
      pasajeroNombre: currentUser.nombre,
      conductorNombre: assignedDriverName,
      vehiculoInfo: assignedVehicleInfo,
      origen: origen.nombre,
      destino: destino.nombre,
      costoCreditos: option.costCredits,
      co2EvitadoKg: option.co2SavingsKg,
      distanciaKm: 1.2,
      duracionMin: option.etaMinutes,
      estado: match.matched ? 'Asignado' : 'Sin conductor disponible',
      timestamp: DateTime.now(),
      qrCode: ticket.token,
      qrExpiresAt: ticket.expiresAt,
      origenLat: origen.latitude,
      origenLng: origen.longitude,
      destinoLat: destino.latitude,
      destinoLng: destino.longitude,
    );

    // Deducir créditos
    currentUser.saldoCreditos =
        (currentUser.saldoCreditos - option.costCredits).clamp(0, 99999);
    totalCo2SavingsKg += option.co2SavingsKg;

    currentTrip = newTrip;
    incomingDriverRequest = newTrip;
    isSearchingTrip = false;

    if (match.matched && match.driver != null) {
      currentDriver = UserModel(
        idEmpleado: match.driver!.id,
        nombre: match.driver!.nombre,
        correo: 'conductor@empresa.com',
        departamento: 'Servicio de Transporte',
        telefono: '+52 81 9876 5432',
        turno: 'Turno Matutino',
        saldoCreditos: 680,
        rol: 'Chofer',
        hasVehicle: true,
        vehicleInfo: match.vehicleInfo,
      );
    }

    notifyListeners();
  }

  Future<void> submitReport({
    required String category,
    required String comment,
  }) =>
      _apiService.submitReport(category: category, comment: comment);

  Future<List<Map<String, dynamic>>> getReports() => _apiService.getReports();

  Future<void> resolveReport(String reportId) =>
      _apiService.resolveReport(reportId);

  Future<void> _loadRoutes() async {
    final response = await _apiService.getRoutes();
    routes = response.map(ParkRideRoute.fromApi).toList();
    _activeRouteId = routes.isEmpty ? null : routes.first.id;
    if (routes.isNotEmpty) {
      final departure = routes.first.schedule;
      nextRouteDeparture = departure != null && departure.length >= 5
          ? departure.substring(0, 5)
          : departure;
    }
    notifyListeners();
  }

  Future<void> refreshRoutes() => _loadRoutes();

  ParkRideRoute? _routeForOption(TransportOption option) {
    final expectedType = option.id == 'OPT_02' ? 'van' : 'bus';
    return routes.cast<ParkRideRoute?>().firstWhere(
          (route) => route!.transportType == expectedType && route.isAvailable,
          orElse: () => routes.cast<ParkRideRoute?>().firstWhere(
                (route) => route!.transportType == expectedType,
                orElse: () => null,
              ),
        );
  }

  static String _apiRoleFor(String role) {
    if (ParkRideBusinessRules.isDriverRouteRole(role)) return 'route_driver';
    if (normalizeRole(role) == ParkRideBusinessRules.adminRole)
      return 'supervisor';
    return 'passenger';
  }

  static String _apiTransportType(TransportOption option) {
    if (option.id == 'OPT_02') return 'van';
    if (option.id == 'OPT_03') return 'carpool';
    return 'shuttle';
  }

  static UserModel _userFromApi(Map<String, dynamic> user) {
    return UserModel(
      idEmpleado: user['id'].toString(),
      nombre: user['name'].toString(),
      correo: user['email'].toString(),
      departamento: (user['department'] ?? 'Sin departamento').toString(),
      empresa: (user['company'] ?? 'ParkRide').toString(),
      telefono: (user['phone'] ?? '+52 81 0000 0000').toString(),
      turno: (user['shift'] ?? 'Turno Matutino').toString(),
      saldoCreditos: 450,
      rol: normalizeRole(user['role']?.toString()),
      hasVehicle: (user['carpool_vehicles'] as List? ?? const []).isNotEmpty ||
          ParkRideBusinessRules.isDriverRole(user['role']?.toString()),
      isVolunteerDriver: user['is_volunteer_driver'] == true,
      carpoolVehicles: (user['carpool_vehicles'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      carpoolAvenues: (user['carpool_avenues'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      isAvailableForCarpooling: user['is_available_for_carpooling'] == true,
      volunteerStatus: user['volunteer_status']?.toString() ?? 'offline',
      carpoolDestination: user['carpool_destination']?.toString(),
      carpoolRoute: (user['carpool_route'] as List? ?? const []).map((point) {
        final item = Map<String, dynamic>.from(point as Map);
        return LatLng((item['latitude'] as num).toDouble(),
            (item['longitude'] as num).toDouble());
      }).toList(),
    );
  }

  Future<void> saveVolunteerProfile({
    required List<Map<String, dynamic>> vehicles,
    required List<String> avenues,
    required bool enabled,
  }) async {
    if (enabled && vehicles.isEmpty) {
      throw StateError(
          'Registra al menos un vehículo para ser conductor voluntario.');
    }
    if (enabled && avenues.length < 2) {
      throw StateError('Selecciona al menos dos avenidas de cobertura.');
    }
    final response =
        await _apiService.updateCurrentUser(currentUser.idEmpleado, {
      'is_volunteer_driver': enabled,
      'carpool_vehicles': vehicles,
      'carpool_avenues': avenues,
    });
    final updated = _userFromApi(response);
    currentUser = updated.copyWith(rol: normalizeRole(updated.rol));
    notifyListeners();
  }

  void acceptDriverTrip() {
    if (incomingDriverRequest != null) {
      driverStatus = "En camino a origen";
      _supabaseService.updateTripStatus(
          incomingDriverRequest!.idViaje, 'Asignado');
      notifyListeners();
    }
  }

  void startTrip() {
    driverStatus = "En viaje con pasajero";
    if (currentTrip != null) {
      _supabaseService.updateTripStatus(currentTrip!.idViaje, 'En curso');
    }
    notifyListeners();
  }

  void completeCurrentTrip() {
    if (currentTrip != null) {
      final finishedTrip = TripModel(
        idViaje: currentTrip!.idViaje,
        pasajeroNombre: currentTrip!.pasajeroNombre,
        conductorNombre: currentTrip!.conductorNombre,
        vehiculoInfo: currentTrip!.vehiculoInfo,
        origen: currentTrip!.origen,
        destino: currentTrip!.destino,
        costoCreditos: currentTrip!.costoCreditos,
        co2EvitadoKg: currentTrip!.co2EvitadoKg,
        distanciaKm: currentTrip!.distanciaKm,
        duracionMin: currentTrip!.duracionMin,
        estado: 'Completado',
        timestamp: currentTrip!.timestamp,
        qrCode: currentTrip!.qrCode,
        qrExpiresAt: currentTrip!.qrExpiresAt,
        origenLat: currentTrip!.origenLat,
        origenLng: currentTrip!.origenLng,
        destinoLat: currentTrip!.destinoLat,
        destinoLng: currentTrip!.destinoLng,
      );

      tripHistory.insert(0, finishedTrip);
      _supabaseService.updateTripStatus(finishedTrip.idViaje, 'Finalizado');
      currentTrip = null;
      incomingDriverRequest = null;
      driverStatus = "Disponible";
      notifyListeners();
    }
  }

  void finishCurrentTrip() => completeCurrentTrip();

  void cancelCurrentTrip() {
    if (currentTrip != null) {
      currentUser.saldoCreditos += currentTrip!.costoCreditos;
      _supabaseService.updateTripStatus(currentTrip!.idViaje, 'Cancelado');
      currentTrip = null;
      incomingDriverRequest = null;
      driverStatus = "Disponible";
      notifyListeners();
    }
  }

  Future<void> toggleDriverOnline(bool online) async {
    isDriverOnline = online;
    driverStatus = online ? "Disponible" : "Desconectado";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('parkride_driver_online', online);
    await prefs.setString('parkride_driver_status', driverStatus);

    await _supabaseService.syncDriverAvailability(
      driverId: currentDriver.idEmpleado,
      driverName: currentDriver.nombre,
      isOnline: online,
      status: driverStatus,
      departamento: currentDriver.departamento,
      vehicleInfo: currentDriver.vehicleInfo,
    );

    notifyListeners();
  }
}
