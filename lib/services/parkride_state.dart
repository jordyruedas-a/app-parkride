import 'package:flutter/material.dart';
import '../models/parkride_models.dart';

class ParkRideState extends ChangeNotifier {
  static final ParkRideState _instance = ParkRideState._internal();
  factory ParkRideState() => _instance;
  ParkRideState._internal();

  // Active User
  UserModel currentUser = UserModel(
    idEmpleado: 'EMP-84920',
    nombre: 'Raúl Jiménez Beltrán',
    correo: 'raul.jimenez@corporativo.com',
    departamento: 'Tecnología e Innovación',
    telefono: '+52 81 2345 6789',
    turno: 'Turno Mañana (07:00 - 15:00)',
    saldoCreditos: 450,
    rol: 'Pasajero',
    hasVehicle: true,
    vehicleInfo: 'Nissan Leaf 2024 (PRK-2048)',
  );

  // Stats
  double totalCo2SavingsKg = 2.5;

  // Active Driver Info
  UserModel currentDriver = UserModel(
    idEmpleado: 'CON-10942',
    nombre: 'Juan Pérez Ochoa',
    correo: 'juan.perez@corporativo.com',
    departamento: 'Logística e Instalaciones',
    telefono: '+52 81 9876 5432',
    turno: 'Turno Mañana (07:00 - 15:00)',
    saldoCreditos: 680,
    rol: 'Conductor',
    hasVehicle: true,
    vehicleInfo: 'Carrito Eléctrico #01',
  );

  bool isDriverModeActive = false;

  // Location Nodes Catalog (Park industrial perimeter nodes)
  final List<LocationNode> nodes = [
    LocationNode(id: 'NODE_01', nombre: 'Nave A', zona: 'Zona Norte', xRatio: 0.25, yRatio: 0.25, iconType: 'factory'),
    LocationNode(id: 'NODE_02', nombre: 'Nave B', zona: 'Zona Norte', xRatio: 0.50, yRatio: 0.20, iconType: 'factory'),
    LocationNode(id: 'NODE_03', nombre: 'Nave C', zona: 'Zona Este', xRatio: 0.75, yRatio: 0.30, iconType: 'factory'),
    LocationNode(id: 'NODE_04', nombre: 'Nave D', zona: 'Zona Este', xRatio: 0.80, yRatio: 0.55, iconType: 'factory'),
    LocationNode(id: 'NODE_05', nombre: 'Nave E', zona: 'Zona Sur', xRatio: 0.65, yRatio: 0.75, iconType: 'factory'),
    LocationNode(id: 'NODE_06', nombre: 'Nave F', zona: 'Zona Sur', xRatio: 0.35, yRatio: 0.80, iconType: 'factory'),
    LocationNode(id: 'NODE_07', nombre: 'Comedor B', zona: 'Zona Central', xRatio: 0.45, yRatio: 0.45, iconType: 'restaurant'),
    LocationNode(id: 'NODE_08', nombre: 'Administración A', zona: 'Zona Central', xRatio: 0.30, yRatio: 0.40, iconType: 'business'),
    LocationNode(id: 'NODE_09', nombre: 'Administración B', zona: 'Zona Central', xRatio: 0.60, yRatio: 0.40, iconType: 'business'),
    LocationNode(id: 'NODE_10', nombre: 'Bodega A', zona: 'Zona Oeste', xRatio: 0.15, yRatio: 0.60, iconType: 'warehouse'),
    LocationNode(id: 'NODE_11', nombre: 'Bodega B', zona: 'Zona Oeste', xRatio: 0.18, yRatio: 0.75, iconType: 'warehouse'),
    LocationNode(id: 'NODE_12', nombre: 'Bodega C', zona: 'Zona Sur', xRatio: 0.70, yRatio: 0.85, iconType: 'warehouse'),
  ];

  // Transport options
  final List<TransportOption> availableOptions = [
    TransportOption(id: 'OPT_01', title: 'Carrito Eléctrico', type: 'Eco-Vehicle', costCredits: 12, etaMinutes: 3, co2SavingsKg: 0.8, iconName: 'electric_car'),
    TransportOption(id: 'OPT_02', title: 'Van Corporativa', type: 'Van', costCredits: 8, etaMinutes: 5, co2SavingsKg: 0.6, iconName: 'airport_shuttle'),
    TransportOption(id: 'OPT_03', title: 'E-Scooter', type: 'Micromovilidad', costCredits: 5, etaMinutes: 2, co2SavingsKg: 0.4, iconName: 'two_wheeler'),
    TransportOption(id: 'OPT_04', title: 'Bicicleta Ecológica', type: 'Micromovilidad', costCredits: 3, etaMinutes: 1, co2SavingsKg: 0.3, iconName: 'pedal_bike'),
    TransportOption(id: 'OPT_05', title: 'Shuttle Express', type: 'Bus', costCredits: 2, etaMinutes: 8, co2SavingsKg: 0.5, iconName: 'directions_bus'),
  ];

  // Active Trip state
  TripModel? currentTrip;
  bool isSearchingTrip = false;

  // Recent trips history
  List<TripModel> tripHistory = [
    TripModel(
      idViaje: 'PR-2841',
      pasajeroNombre: 'Raúl Jiménez Beltrán',
      conductorNombre: 'Juan Pérez Ochoa',
      vehiculoInfo: 'Carrito Eléctrico #01',
      origen: 'Nave A',
      destino: 'Comedor B',
      costoCreditos: 12,
      co2EvitadoKg: 0.8,
      distanciaKm: 1.2,
      duracionMin: 8,
      estado: 'Completado',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      qrCode: 'PR-2841-XYZ',
    ),
    TripModel(
      idViaje: 'PR-2790',
      pasajeroNombre: 'Raúl Jiménez Beltrán',
      conductorNombre: 'María Torres',
      vehiculoInfo: 'Van Corporativa #04',
      origen: 'Administración A',
      destino: 'Estac. Zona E2',
      costoCreditos: 15,
      co2EvitadoKg: 0.9,
      distanciaKm: 1.8,
      duracionMin: 12,
      estado: 'Completado',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      qrCode: 'PR-2790-ABC',
    ),
    TripModel(
      idViaje: 'PR-2710',
      pasajeroNombre: 'Raúl Jiménez Beltrán',
      conductorNombre: 'Carlos Ruiz',
      vehiculoInfo: 'E-Scooter #12',
      origen: 'Bodega A',
      destino: 'Nave C',
      costoCreditos: 0,
      co2EvitadoKg: 0.0,
      distanciaKm: 0.5,
      duracionMin: 0,
      estado: 'Cancelado',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      qrCode: 'PR-2710-CANCEL',
    ),
    TripModel(
      idViaje: 'PR-2655',
      pasajeroNombre: 'Raúl Jiménez Beltrán',
      conductorNombre: 'Juan Pérez Ochoa',
      vehiculoInfo: 'Carrito Eléctrico #01',
      origen: 'Acceso Norte',
      destino: 'Nave A',
      costoCreditos: 8,
      co2EvitadoKg: 0.5,
      distanciaKm: 0.9,
      duracionMin: 6,
      estado: 'Completado',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      qrCode: 'PR-2655-OK',
    ),
  ];

  // Transactions list
  List<TransactionModel> transactions = [
    TransactionModel(idTransaccion: 'TX-901', montoCreditos: 12, fecha: DateTime.now().subtract(const Duration(hours: 2)), motivo: 'Pago de viaje (Nave A -> Comedor B)', isDeduction: true),
    TransactionModel(idTransaccion: 'TX-890', montoCreditos: 50, fecha: DateTime.now().subtract(const Duration(days: 2)), motivo: 'Recompensa por compartir viaje', isDeduction: false),
    TransactionModel(idTransaccion: 'TX-800', montoCreditos: 500, fecha: DateTime.now().subtract(const Duration(days: 15)), motivo: 'Recarga Mensual Corporativa', isDeduction: false),
  ];

  // Core Matching Algorithm logic
  Future<TripModel> createTripRequest({
    required String origen,
    required String destino,
    required TransportOption option,
  }) async {
    isSearchingTrip = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // Calculate credits deduction
    if (currentUser.saldoCreditos >= option.costCredits) {
      currentUser.saldoCreditos -= option.costCredits;
      totalCo2SavingsKg += option.co2SavingsKg;

      transactions.insert(
        0,
        TransactionModel(
          idTransaccion: 'TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          montoCreditos: option.costCredits,
          fecha: DateTime.now(),
          motivo: 'Pago de viaje ($origen -> $destino)',
          isDeduction: true,
        ),
      );
    }

    final newTrip = TripModel(
      idViaje: 'PR-${(2842 + tripHistory.length).toString()}',
      pasajeroNombre: currentUser.nombre,
      conductorNombre: currentDriver.nombre,
      vehiculoInfo: '${option.title} #01',
      origen: origen,
      destino: destino,
      costoCreditos: option.costCredits,
      co2EvitadoKg: option.co2SavingsKg,
      distanciaKm: 1.2,
      duracionMin: option.etaMinutes + 4,
      estado: 'En curso',
      timestamp: DateTime.now(),
      qrCode: 'PR-${(2842 + tripHistory.length).toString()}',
    );

    currentTrip = newTrip;
    isSearchingTrip = false;
    notifyListeners();
    return newTrip;
  }

  void finishCurrentTrip() {
    if (currentTrip != null) {
      final completedTrip = TripModel(
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
      );
      tripHistory.insert(0, completedTrip);
      currentTrip = null;
      notifyListeners();
    }
  }

  void toggleDriverMode(bool value) {
    isDriverModeActive = value;
    notifyListeners();
  }

  void loginUser(String email, String password) {
    if (email.contains('juan') || email.contains('conductor')) {
      currentUser = currentDriver;
    }
    notifyListeners();
  }
}
