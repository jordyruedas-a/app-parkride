import 'package:flutter_test/flutter_test.dart';
import 'package:parkride/services/supabase_config.dart';
import 'package:parkride/services/supabase_service.dart';

void main() {
  group('Supabase demo auth', () {
    test('pasajero demo credentials are accepted', () {
      expect(
        SupabaseService.matchesDemoCredentials(
          'pasajero@parkride.com',
          'ParkRide2026!',
        ),
        isTrue,
      );

      final user = SupabaseService.demoUserForEmail('pasajero@parkride.com');
      expect(user.rol, 'Pasajero');
      expect(user.correo, 'pasajero@parkride.com');
    });

    test('chofer demo credentials are accepted', () {
      expect(
        SupabaseService.matchesDemoCredentials(
          'chofer@parkride.com',
          'Chofer2026!',
        ),
        isTrue,
      );

      final user = SupabaseService.demoUserForEmail('chofer@parkride.com');
      expect(user.rol.toLowerCase(), contains('chofer'));
      expect(user.correo, 'chofer@parkride.com');
    });

    test('supervisor demo credentials are accepted', () {
      expect(
        SupabaseService.matchesDemoCredentials(
          'supervisor@parkride.com',
          'Admin2026!',
        ),
        isTrue,
      );

      final user = SupabaseService.demoUserForEmail('supervisor@parkride.com');
      expect(user.rol, 'Supervisor');
      expect(user.correo, 'supervisor@parkride.com');
    });
  });
}
