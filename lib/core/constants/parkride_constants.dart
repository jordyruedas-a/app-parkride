class ParkRideConstants {
  static const String appName = 'ParkRide';
  static const String brandPrimary = '#22C55E';
  static const String brandDark = '#0F172A';
  static const List<String> allowedTransportTypes = [
    'shuttle',
    'van',
    'carpool'
  ];
  static const int qrValidityMinutes = 15;
  static const String defaultDriverPassword = 'driver123';
  static const String defaultPassengerPassword = 'passenger123';
  static const String defaultAdminPassword = 'admin123';
}

class ParkRideSeedData {
  static List<UserSeed> seedUsers() {
    return [
      UserSeed(
        name: 'Ana García',
        email: 'passenger@parkride.com',
        role: 'passenger',
        password: ParkRideConstants.defaultPassengerPassword,
      ),
      UserSeed(
        name: 'Luis Moreno',
        email: 'driver@parkride.com',
        role: 'driver',
        password: ParkRideConstants.defaultDriverPassword,
      ),
      UserSeed(
        name: 'Valeria Torres',
        email: 'admin@parkride.com',
        role: 'admin',
        password: ParkRideConstants.defaultAdminPassword,
      ),
    ];
  }
}

class UserSeed {
  final String name;
  final String email;
  final String role;
  final String password;

  const UserSeed({
    required this.name,
    required this.email,
    required this.role,
    required this.password,
  });
}
