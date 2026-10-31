import 'package:flutter_test/flutter_test.dart';
import 'package:parkride/services/parkride_api_service.dart';

void main() {
  group('ParkRide API', () {
    test('uses the Android emulator backend endpoint by default', () {
      expect(ParkRideApiService.baseUrl, 'http://10.0.2.2:8000');
    });
  });
}
