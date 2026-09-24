import 'package:flutter_test/flutter_test.dart';
import 'package:parkride/main.dart';

void main() {
  testWidgets('ParkRide app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ParkRideApp());
    expect(find.text('Mi Movilidad'), findsOneWidget);
  });
}
