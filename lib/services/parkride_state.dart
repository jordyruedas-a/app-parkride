import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parkride_models.dart';
import 'airport_route_service.dart';
import 'location_service.dart';
import 'ride_matching_service.dart';
import 'supabase_service.dart';

class ParkRideState extends ChangeNotifier {
  static final ParkRideState _instance = ParkRideState._internal();
  factory ParkRideState() => _instance;
  ParkRideState._internal();

  final SupabaseService _supabaseService = SupabaseService();

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

  static String normalizeRole(String? role) {
    final value = (role ?? 'Pasajero').trim();
    final lower = value.toLowerCase();

    if (lower.contains('supervisor') || lower.contains('admin')) {
      return 'Admin';
    }
    if (lower.contains('ruta') || lower.contains('route') || lower.contains('route_driver')) {
      return 'Chofer de Ruta';
    }
    if (lower.contains('conductor') || lower.contains('chofer') || lower.contains('driver')) {
      return 'Chofer';
    }
    return 'Pasajero';
  }

  // Métodos de autenticación integrados con Supabase
  Future<void> loginUser(String email, String password) async {
    final user = await _supabaseService.signIn(email: email, password: password);
    final normalizedRole = normalizeRole(user.rol);
    currentUser = user.copyWith(rol: normalizedRole);
    if (normalizedRole.contains('Ruta') || normalizedRole.contains('Chofer')) {
      currentDriver = currentUser;
    }
    notifyListeners();
  }

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
    final user = await _supabaseService.signUp(
      email: email,
      password: password,
      nombre: nombre,
      rol: normalizedRol,
      empresa: empresa,
      departamento: departamento,
      telefono: telefono,
      numEmpleado: numEmpleado,
      vehicleInfo: vehicleInfo,
    );
    currentUser = user.copyWith(rol: normalizedRol);
    if (normalizedRol.contains('Ruta') || normalizedRol.contains('Chofer')) {
      currentDriver = currentUser;
    }
    notifyListeners();
  }

  void logout() {
    _supabaseService.signOut();
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
    requestTrip(origen: origenNode, destino: destinoNode, option: option);
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

  void requestTrip({
    required LocationNode origen,
    required LocationNode destino,
    required TransportOption option,
  }) {
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

    final qrExpiry = DateTime.now().add(const Duration(minutes: 15));
    final newTrip = TripModel(
      idViaje: 'PR-${DateTime.now().millisecondsSinceEpoch % 10000}',
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
      qrCode: 'PR-QR-${DateTime.now().millisecondsSinceEpoch}',
      qrExpiresAt: qrExpiry,
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

    // Guardar en Supabase asíncronamente
    _supabaseService.requestTrip(newTrip);

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
