import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkride/main.dart';
import 'package:parkride/models/parkride_models.dart';
import 'package:parkride/screens/ViajeEnCurso.dart';
import 'package:parkride/services/parkride_state.dart';

void main() {
  testWidgets('ParkRide app loads the corporate login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParkRideApp());

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Accede con tu cuenta corporativa'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('8126433544'), findsOneWidget);
    expect(
      find.textContaining('favor contacta al servicio técnico'),
      findsOneWidget,
    );
  });

  testWidgets('ViajeEnCurso stays within small screen widths',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(() => tester.view.resetPhysicalSize());

    // Configurar viaje activo para prueba
    ParkRideState().currentTrip = TripModel(
      idViaje: 'TEST-001',
      pasajeroNombre: 'Pasajero Test',
      conductorNombre: 'Chofer Test',
      vehiculoInfo: 'Van de Transporte #01',
      origen: 'Parque Industrial',
      destino: 'Zona Sur',
      costoCreditos: 10,
      co2EvitadoKg: 1.2,
      distanciaKm: 4.5,
      duracionMin: 15,
      estado: 'En curso',
      timestamp: DateTime.now(),
      qrCode: 'PR-TEST-QR',
      qrExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
      origenLat: 25.7252,
      origenLng: -100.3131,
      destinoLat: 25.6866,
      destinoLng: -100.3161,
    );

    await tester.pumpWidget(const MaterialApp(home: ViajeEnCurso()));

    expect(find.text('Finalizar Viaje'), findsOneWidget);
    expect(find.text('Ver Mi Pase de Abordaje (QR)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
