class ParkRideBusinessRules {
  static const String driverRouteRole = 'Chofer de Ruta';
  static const String driverRole = 'Chofer';
  static const String adminRole = 'Admin';
  static const String passengerRole = 'Pasajero';

  static String normalizeRole(String? role) {
    final value = (role ?? passengerRole).trim();
    final lower = value.toLowerCase();

    if (lower.contains('supervisor') || lower.contains('admin')) {
      return adminRole;
    }
    if (lower.contains('ruta') ||
        lower.contains('route') ||
        lower.contains('route_driver') ||
        lower.contains('driver route')) {
      return driverRouteRole;
    }
    if (lower.contains('conductor') ||
        lower.contains('chofer') ||
        lower.contains('driver')) {
      return driverRole;
    }
    return passengerRole;
  }

  static bool isDriverRole(String? role) {
    final normalized = normalizeRole(role);
    return normalized == driverRole || normalized == driverRouteRole;
  }

  static bool isDriverRouteRole(String? role) {
    return normalizeRole(role) == driverRouteRole;
  }

  static bool isPassengerRole(String? role) {
    return normalizeRole(role) == passengerRole;
  }

  static String routeCompletionMessage(String nextDeparture) {
    final cleaned = nextDeparture.trim();
    return 'Ruta finalizada. Próximo horario: $cleaned';
  }
}
