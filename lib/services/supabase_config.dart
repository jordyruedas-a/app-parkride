/// Configuración centralizada de Supabase para ParkRide
/// Aquí puedes colocar la URL y la Llave Anónima de tu proyecto de Supabase.
class SupabaseConfig {
  // Configuración oficial de Supabase — Proyecto: park ride (ACTIVO)
  static const String supabaseUrl = 'https://jnhokhsilyfqkpwbbsyk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpuaG9raHNpbHlmcWtwd2Jic3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAwMzkyNDcsImV4cCI6MjEwNTYxNTI0N30.Pj5z9w3xkAh8En_dCdpUsM8HPfEeqx_wVmPXuCh4zvA';

  /// Determina si las credenciales fueron reemplazadas por credenciales válidas
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        !supabaseUrl.contains('TU-PROYECTO') &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseAnonKey.contains('TU_SUPABASE_ANON_KEY');
  }

  // Nombres de tablas en Supabase
  static const String tableProfiles = 'profiles';
  static const String tableTrips = 'trips';
  static const String tableLocations = 'campus_locations';
  static const String tableVehicles = 'vehicles';
  static const String tableTickets = 'tickets';

  static const Map<String, String> cleanDemoAccounts = {};

  static const String defaultPassengerEmail = '';
  static const String defaultPassengerPassword = '';
  static const String defaultDriverEmail = '';
  static const String defaultDriverPassword = '';
  static const String defaultSupervisorEmail = '';
  static const String defaultSupervisorPassword = '';

  /// Script SQL recomendado para crear la estructura relacional en el Editor SQL de Supabase:
  static const String initialSqlSchema = '''
  -- 1. Tabla de Perfiles (Empleados y Choferes Corporativos)
  CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    correo TEXT NOT NULL UNIQUE,
    empresa TEXT DEFAULT 'ParkRide Corp.',
    departamento TEXT DEFAULT 'Sin departamento',
    telefono TEXT,
    turno TEXT DEFAULT 'Matutino',
    saldo_creditos INTEGER DEFAULT 450,
    rol TEXT DEFAULT 'Pasajero', -- 'Pasajero', 'Chofer', 'Supervisor'
    has_vehicle BOOLEAN DEFAULT false,
    vehicle_info TEXT,
    num_empleado TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
  );

  -- 2. Tabla de Viajes de Movilidad (Trips)
  CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pasajero_id UUID REFERENCES auth.users(id),
    pasajero_nombre TEXT NOT NULL,
    conductor_id UUID REFERENCES auth.users(id),
    conductor_nombre TEXT,
    vehiculo_info TEXT,
    origen TEXT NOT NULL,
    destino TEXT NOT NULL,
    origen_lat DOUBLE PRECISION NOT NULL,
    origen_lng DOUBLE PRECISION NOT NULL,
    destino_lat DOUBLE PRECISION NOT NULL,
    destino_lng DOUBLE PRECISION NOT NULL,
    costo_creditos INTEGER DEFAULT 10,
    co2_evitado_kg DOUBLE PRECISION DEFAULT 0.5,
    distancia_km DOUBLE PRECISION DEFAULT 1.0,
    duracion_min INTEGER DEFAULT 5,
    estado TEXT DEFAULT 'En cola',
    qr_code TEXT,
    qr_expires_at TIMESTAMPTZ,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
  );

  -- 3. Tabla de Ubicaciones / Paradas del Campus
  CREATE TABLE IF NOT EXISTS campus_locations (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    zona TEXT NOT NULL,
    icon_type TEXT DEFAULT 'place',
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL
  );

  -- 4. Tabla de tickets QR para validación de acceso por chofer
  CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    passenger_name TEXT NOT NULL,
    passenger_id TEXT,
    status TEXT NOT NULL DEFAULT 'activo',
    expires_at TIMESTAMPTZ,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
  );

  -- Habilitar RLS (Row Level Security)
  ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
  ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
  ALTER TABLE campus_locations ENABLE ROW LEVEL SECURITY;
  ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

  -- Políticas de acceso básicas para pruebas
  CREATE POLICY "Lectura pública de perfiles" ON profiles FOR SELECT USING (true);
  CREATE POLICY "Actualización de propio perfil" ON profiles FOR UPDATE USING (auth.uid() = id);
  CREATE POLICY "Lectura de viajes" ON trips FOR SELECT USING (true);
  CREATE POLICY "Creación de viajes" ON trips FOR INSERT WITH CHECK (true);
  CREATE POLICY "Actualización de viajes" ON trips FOR UPDATE USING (true);
  CREATE POLICY "Lectura de ubicaciones" ON campus_locations FOR SELECT USING (true);
  CREATE POLICY "Lectura de tickets" ON tickets FOR SELECT USING (true);
  CREATE POLICY "Actualización de tickets" ON tickets FOR UPDATE USING (true);
  ''';
}
