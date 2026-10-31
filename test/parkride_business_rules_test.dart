import 'package:flutter_test/flutter_test.dart';
import 'package:parkride/services/parkride_business_rules.dart';

void main() {
  group('ParkRide business rules', () {
    test('normalizes strict driver route role', () {
      expect(ParkRideBusinessRules.normalizeRole('Chofer de Ruta'), 'Chofer de Ruta');
      expect(ParkRideBusinessRules.isDriverRouteRole('Chofer de Ruta'), isTrue);
      expect(ParkRideBusinessRules.isDriverRole('Chofer de Ruta'), isTrue);
    });

    test('builds route completion status with next time', () {
      expect(
        ParkRideBusinessRules.routeCompletionMessage('07:30'),
        'Ruta finalizada. Próximo horario: 07:30',
      );
      expect(
        ParkRideBusinessRules.routeCompletionMessage('Volver al centro de unidades'),
        'Ruta finalizada. Próximo horario: Volver al centro de unidades',
      );
    });
  });
}
