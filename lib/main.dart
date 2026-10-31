import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/ChoferRutaScreen.dart';
import 'screens/ChoferDashboard.dart';
import 'screens/CodigoQRScreen.dart';
import 'screens/HistorialViajesScreen.dart';
import 'screens/ParkrideCrearCuenta.dart';
import 'screens/ParkrideDashboard.dart';
import 'screens/ParkrideLogin.dart';
import 'screens/ParkrideProfileSettings.dart';
import 'screens/ReportesESGScreen.dart';
import 'screens/SolicitarViaje.dart';
import 'screens/SupervisorDashboard.dart';
import 'screens/ViajeEnCurso.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase
  await SupabaseService.initialize();

  runApp(const ParkRideApp());
}

class ParkRideApp extends StatelessWidget {
  const ParkRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkRide',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF1E293B),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
        ),
      ),
      initialRoute: '/ParkrideLogin',
      routes: {
        '/ParkrideDashboard': (context) => const ParkrideDashboard(),
        '/ParkrideLogin': (context) => const ParkrideLogin(),
        '/ParkrideCrearCuenta': (context) => const ParkrideCrearCuenta(),
        '/SolicitarViaje': (context) => const SolicitarViaje(),
        '/ViajeEnCurso': (context) => const ViajeEnCurso(),
        '/ParkrideProfileSettings': (context) =>
            const ParkrideProfileSettings(),
        '/CodigoQR': (context) => const CodigoQRScreen(),
        '/HistorialViajes': (context) => const HistorialViajesScreen(),
        '/ReportesESG': (context) => const ReportesESGScreen(),
        '/SupervisorDashboard': (context) => const SupervisorDashboard(),
        '/ChoferRuta': (context) => const ChoferRutaScreen(),
        '/ChoferDashboard': (context) => const ChoferDashboard(),

      },
    );
  }
}
