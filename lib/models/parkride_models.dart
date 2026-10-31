import 'package:latlong2/latlong.dart';

class UserModel {
  final String idEmpleado;
  final String nombre;
  final String correo;
  final String departamento;
  final String empresa;
  final String telefono;
  final String turno;
  int saldoCreditos;
  final String rol; // Pasajero, Conductor, Admin, Supervisor
  final bool hasVehicle;
  String? vehicleInfo;
  final String? numEmpleado;
  final bool isVolunteerDriver;
  final List<Map<String, dynamic>> carpoolVehicles;
  final List<String> carpoolAvenues;

  UserModel({
    required this.idEmpleado,
    required this.nombre,
    required this.correo,
    String? departamento,
    String? empresa,
    required this.telefono,
    required this.turno,
    required this.saldoCreditos,
    required this.rol,
    this.hasVehicle = false,
    this.vehicleInfo,
    this.numEmpleado,
    this.isVolunteerDriver = false,
    this.carpoolVehicles = const [],
    this.carpoolAvenues = const [],
  })  : departamento = (departamento != null && departamento.trim().isNotEmpty)
            ? departamento
            : (empresa != null && empresa.trim().isNotEmpty)
                ? empresa
                : 'Sin departamento',
        empresa = (empresa != null && empresa.trim().isNotEmpty)
            ? empresa
            : (departamento != null && departamento.trim().isNotEmpty)
                ? departamento
                : 'Sin empresa';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final empresaValue =
        (map['empresa'] ?? map['departamento'] ?? 'Sin empresa').toString();
    final departamentoValue = (map['departamento'] ?? empresaValue).toString();

    return UserModel(
      idEmpleado: map['id_empleado'] ?? map['id'] ?? 'USR-0001',
      nombre: map['nombre'] ?? 'Usuario',
      correo: map['correo'] ?? '',
      departamento: departamentoValue,
      empresa: empresaValue,
      telefono: map['telefono'] ?? '+52 81 0000 0000',
      turno: map['turno'] ?? 'Matutino',
      saldoCreditos: map['saldo_creditos'] is int ? map['saldo_creditos'] : 450,
      rol: map['rol'] ?? 'Pasajero',
      hasVehicle: map['has_vehicle'] ?? false,
      vehicleInfo: map['vehicle_info'],
      numEmpleado: map['num_empleado']?.toString(),
      isVolunteerDriver: map['is_volunteer_driver'] == true,
      carpoolVehicles: (map['carpool_vehicles'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      carpoolAvenues: (map['carpool_avenues'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedEmpresa =
        empresa.trim().isNotEmpty ? empresa : departamento;
    return {
      'id_empleado': idEmpleado,
      'nombre': nombre,
      'correo': correo,
      'departamento': departamento,
      'empresa': normalizedEmpresa,
      'telefono': telefono,
      'turno': turno,
      'saldo_creditos': saldoCreditos,
      'rol': rol,
      'has_vehicle': hasVehicle,
      'vehicle_info': vehicleInfo,
      'num_empleado': numEmpleado,
      'is_volunteer_driver': isVolunteerDriver,
      'carpool_vehicles': carpoolVehicles,
      'carpool_avenues': carpoolAvenues,
    };
  }

  UserModel copyWith({
    String? idEmpleado,
    String? nombre,
    String? correo,
    String? departamento,
    String? empresa,
    String? telefono,
    String? turno,
    int? saldoCreditos,
    String? rol,
    bool? hasVehicle,
    String? vehicleInfo,
    String? numEmpleado,
    bool? isVolunteerDriver,
    List<Map<String, dynamic>>? carpoolVehicles,
    List<String>? carpoolAvenues,
  }) {
    return UserModel(
      idEmpleado: idEmpleado ?? this.idEmpleado,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      departamento: departamento ?? this.departamento,
      empresa: empresa ?? this.empresa,
      telefono: telefono ?? this.telefono,
      turno: turno ?? this.turno,
      saldoCreditos: saldoCreditos ?? this.saldoCreditos,
      rol: rol ?? this.rol,
      hasVehicle: hasVehicle ?? this.hasVehicle,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      numEmpleado: numEmpleado ?? this.numEmpleado,
      isVolunteerDriver: isVolunteerDriver ?? this.isVolunteerDriver,
      carpoolVehicles: carpoolVehicles ?? this.carpoolVehicles,
      carpoolAvenues: carpoolAvenues ?? this.carpoolAvenues,
    );
  }
}

class LocationNode {
  final String id;
  final String nombre;
  final String zona;
  final double xRatio;
  final double yRatio;
  final String iconType;
  final double latitude;
  final double longitude;

  LocationNode({
    required this.id,
    required this.nombre,
    required this.zona,
    this.xRatio = 0.5,
    this.yRatio = 0.5,
    required this.iconType,
    this.latitude = 25.7252,
    this.longitude = -100.3131,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory LocationNode.fromMap(Map<String, dynamic> map) {
    return LocationNode(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      zona: map['zona'] ?? '',
      xRatio: (map['x_ratio'] as num?)?.toDouble() ?? 0.5,
      yRatio: (map['y_ratio'] as num?)?.toDouble() ?? 0.5,
      iconType: map['icon_type'] ?? 'place',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 25.7252,
      longitude: (map['longitude'] as num?)?.toDouble() ?? -100.3131,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'zona': zona,
      'icon_type': iconType,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ParkRideRoute {
  final String id;
  final String name;
  final String transportType;
  final String color;
  final String schedule;
  final bool isAvailable;
  final String? driverName;
  final String? vehicleLabel;
  final List<LocationNode> stops;

  const ParkRideRoute({
    required this.id,
    required this.name,
    required this.transportType,
    required this.color,
    required this.schedule,
    required this.isAvailable,
    required this.stops,
    this.driverName,
    this.vehicleLabel,
  });

  factory ParkRideRoute.fromApi(Map<String, dynamic> data) {
    final rawStops = data['stops'] as List? ?? const [];
    final stops = rawStops.map((raw) {
      final stop = Map<String, dynamic>.from(raw as Map);
      return LocationNode(
        id: stop['id']?.toString() ?? '',
        nombre: stop['stop_name']?.toString() ?? 'Parada',
        zona: data['name']?.toString() ?? 'Ruta',
        iconType: 'place',
        latitude: (stop['latitude'] as num?)?.toDouble() ?? 25.7252,
        longitude: (stop['longitude'] as num?)?.toDouble() ?? -100.3131,
      );
    }).toList();
    final vehicle = data['vehicle'];
    final driver = data['driver'];
    return ParkRideRoute(
      id: data['id'].toString(),
      name: data['name']?.toString() ?? 'Ruta ParkRide',
      transportType: data['transport_type']?.toString() ?? 'bus',
      color: data['color']?.toString() ?? '#2563EB',
      schedule: data['departure_time']?.toString() ?? 'Sin horario',
      isAvailable: data['is_available'] == true,
      stops: stops,
      driverName: driver is Map ? driver['name']?.toString() : null,
      vehicleLabel: vehicle is Map
          ? '${vehicle['model'] ?? 'Unidad'} • ${vehicle['plate'] ?? ''}'
          : null,
    );
  }
}

class TransportOption {
  final String id;
  final String title;
  final String type;
  final int costCredits;
  final int etaMinutes;
  final double co2SavingsKg;
  final String iconName;

  TransportOption({
    required this.id,
    required this.title,
    required this.type,
    required this.costCredits,
    required this.etaMinutes,
    required this.co2SavingsKg,
    required this.iconName,
  });
}

class VehicleModel {
  final String idVehiculo;
  final String tipo;
  final int capacidadPasajeros;
  final String placaNumero;
  final String propietario;
  final String color;
  final String estado;
  final double currentLat;
  final double currentLng;

  VehicleModel({
    required this.idVehiculo,
    required this.tipo,
    required this.capacidadPasajeros,
    required this.placaNumero,
    required this.propietario,
    required this.color,
    this.estado = 'ACTIVO',
    this.currentLat = 25.7252,
    this.currentLng = -100.3131,
  });

  LatLng get latLng => LatLng(currentLat, currentLng);
}

class TripModel {
  final String idViaje;
  final String pasajeroNombre;
  final String conductorNombre;
  final String vehiculoInfo;
  final String origen;
  final String destino;
  final int costoCreditos;
  final double co2EvitadoKg;
  final double distanciaKm;
  final int duracionMin;
  final String estado;
  final DateTime timestamp;
  final String qrCode;
  final DateTime? qrExpiresAt;
  final double origenLat;
  final double origenLng;
  final double destinoLat;
  final double destinoLng;

  TripModel({
    required this.idViaje,
    required this.pasajeroNombre,
    required this.conductorNombre,
    required this.vehiculoInfo,
    required this.origen,
    required this.destino,
    required this.costoCreditos,
    required this.co2EvitadoKg,
    required this.distanciaKm,
    required this.duracionMin,
    required this.estado,
    required this.timestamp,
    required this.qrCode,
    this.qrExpiresAt,
    this.origenLat = 25.7252,
    this.origenLng = -100.3131,
    this.destinoLat = 25.7280,
    this.destinoLng = -100.3110,
  });

  bool get isQrExpired {
    if (qrExpiresAt == null) return false;
    return DateTime.now().isAfter(qrExpiresAt!);
  }

  Duration get qrTimeRemaining {
    if (qrExpiresAt == null) return Duration.zero;
    final remaining = qrExpiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  LatLng get origenLatLng => LatLng(origenLat, origenLng);
  LatLng get destinoLatLng => LatLng(destinoLat, destinoLng);

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      idViaje: map['id_viaje'] ?? map['id'] ?? '',
      pasajeroNombre: map['pasajero_nombre'] ?? 'Pasajero',
      conductorNombre: map['conductor_nombre'] ?? 'Conductor',
      vehiculoInfo: map['vehiculo_info'] ?? 'Unidad de Transporte',
      origen: map['origen'] ?? 'Origen',
      destino: map['destino'] ?? 'Destino',
      costoCreditos: map['costo_creditos'] is int ? map['costo_creditos'] : 10,
      co2EvitadoKg: (map['co2_evitado_kg'] as num?)?.toDouble() ?? 0.5,
      distanciaKm: (map['distancia_km'] as num?)?.toDouble() ?? 1.0,
      duracionMin: map['duracion_min'] is int ? map['duracion_min'] : 5,
      estado: map['estado'] ?? 'En cola',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      qrCode: map['qr_code'] ?? 'PR-QR',
      qrExpiresAt: map['qr_expires_at'] != null
          ? DateTime.tryParse(map['qr_expires_at'].toString())
          : null,
      origenLat: (map['origen_lat'] as num?)?.toDouble() ?? 25.7252,
      origenLng: (map['origen_lng'] as num?)?.toDouble() ?? -100.3131,
      destinoLat: (map['destino_lat'] as num?)?.toDouble() ?? 25.7280,
      destinoLng: (map['destino_lng'] as num?)?.toDouble() ?? -100.3110,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_viaje': idViaje,
      'pasajero_nombre': pasajeroNombre,
      'conductor_nombre': conductorNombre,
      'vehiculo_info': vehiculoInfo,
      'origen': origen,
      'destino': destino,
      'costo_creditos': costoCreditos,
      'co2_evitado_kg': co2EvitadoKg,
      'distancia_km': distanciaKm,
      'duracion_min': duracionMin,
      'estado': estado,
      'timestamp': timestamp.toIso8601String(),
      'qr_code': qrCode,
      'qr_expires_at': qrExpiresAt?.toIso8601String(),
      'origen_lat': origenLat,
      'origen_lng': origenLng,
      'destino_lat': destinoLat,
      'destino_lng': destinoLng,
    };
  }
}

class TransactionModel {
  final String idTransaccion;
  final int montoCreditos;
  final DateTime fecha;
  final String motivo;
  final bool isDeduction;

  TransactionModel({
    required this.idTransaccion,
    required this.montoCreditos,
    required this.fecha,
    required this.motivo,
    required this.isDeduction,
  });
}
