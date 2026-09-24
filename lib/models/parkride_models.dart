class UserModel {
  final String idEmpleado;
  final String nombre;
  final String correo;
  final String departamento;
  final String telefono;
  final String turno;
  int saldoCreditos;
  final String rol; // Pasajero, Conductor, Admin
  final bool hasVehicle;
  final String? vehicleInfo;

  UserModel({
    required this.idEmpleado,
    required this.nombre,
    required this.correo,
    required this.departamento,
    required this.telefono,
    required this.turno,
    required this.saldoCreditos,
    required this.rol,
    this.hasVehicle = false,
    this.vehicleInfo,
  });
}

class LocationNode {
  final String id;
  final String nombre;
  final String zona;
  final double xRatio; // Relative position on map (0.0 to 1.0)
  final double yRatio;
  final String iconType;

  LocationNode({
    required this.id,
    required this.nombre,
    required this.zona,
    required this.xRatio,
    required this.yRatio,
    required this.iconType,
  });
}

class TransportOption {
  final String id;
  final String title;
  final String type; // Carrito Eléctrico, Van, E-Scooter, Bicicleta, Shuttle
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
  final String tipo; // Carrito, Van, Auto Eléctrico
  final int capacidadPasajeros;
  final String placaNumero;
  final String propietario;
  final String color;
  final String estado; // ACTIVO, EN VIAJE, MANTENIMIENTO

  VehicleModel({
    required this.idVehiculo,
    required this.tipo,
    required this.capacidadPasajeros,
    required this.placaNumero,
    required this.propietario,
    required this.color,
    this.estado = 'ACTIVO',
  });
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
  final String estado; // En cola, Asignado, En curso, Finalizado, Cancelado
  final DateTime timestamp;
  final String qrCode;

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
  });
}

class TransactionModel {
  final String idTransaccion;
  final int montoCreditos;
  final DateTime fecha;
  final String motivo; // Pago de viaje, Recarga mensual, Recompensa ambiental
  final bool isDeduction;

  TransactionModel({
    required this.idTransaccion,
    required this.montoCreditos,
    required this.fecha,
    required this.motivo,
    required this.isDeduction,
  });
}
