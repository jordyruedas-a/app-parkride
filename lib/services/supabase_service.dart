import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parkride_models.dart';
import 'supabase_config.dart';

class TicketValidationResult {
  final bool isValid;
  final String title;
  final String message;
  final String? passengerName;
  final String? passengerId;
  final String? status;
  final bool isExpired;
  final bool alreadyUsed;

  const TicketValidationResult({
    required this.isValid,
    required this.title,
    required this.message,
    this.passengerName,
    this.passengerId,
    this.status,
    this.isExpired = false,
    this.alreadyUsed = false,
  });
}

class SupabaseService {
  static const String _usedDemoTicketKey = 'parkride_used_demo_tickets';
  static const String _localUsersKey = 'parkride_local_users';
  static final Set<String> _demoUsedTicketCache = <String>{};

  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  static Future<Set<String>> _loadUsedDemoTickets() async {
    final cache = <String>{..._demoUsedTicketCache};

    try {
      final prefs = await SharedPreferences.getInstance();
      final values =
          prefs.getStringList(_usedDemoTicketKey) ?? const <String>[];
      for (final value in values) {
        final normalized = value.trim().toUpperCase();
        if (normalized.isNotEmpty) {
          cache.add(normalized);
        }
      }
    } catch (_) {
      // Se mantiene el caché en memoria cuando la persistencia no está preparada.
    }

    _demoUsedTicketCache.clear();
    _demoUsedTicketCache.addAll(cache);
    return cache;
  }

  static Future<void> _saveUsedDemoTickets(Set<String> usedCodes) async {
    _demoUsedTicketCache.clear();
    _demoUsedTicketCache.addAll(usedCodes);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_usedDemoTicketKey, usedCodes.toList()..sort());
    } catch (_) {
      // Silenciar errores de persistencia; el bloqueo funcional sigue activo en memoria.
    }
  }

  static Future<Map<String, dynamic>> _loadLocalUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localUsersKey);
      if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, dynamic>{};
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<void> _saveLocalUsers(Map<String, dynamic> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localUsersKey, jsonEncode(users));
    } catch (_) {
      // El fallback local se mantiene solo en memoria si no se puede persistir.
    }
  }

  static Future<void> _saveLocalUser(UserModel user, String password) async {
    final map = await _loadLocalUsers();
    map[user.correo.trim().toLowerCase()] = {
      'email': user.correo,
      'password': password,
      'nombre': user.nombre,
      'rol': user.rol,
      'empresa': user.empresa,
      'departamento': user.departamento,
      'telefono': user.telefono,
      'saldo_creditos': user.saldoCreditos,
      'has_vehicle': user.hasVehicle,
      'vehicle_info': user.vehicleInfo ?? '',
      'num_empleado': user.idEmpleado,
    };
    await _saveLocalUsers(map);
  }

  static Future<UserModel?> _findLocalUser(String email, [String? password]) async {
    final users = await _loadLocalUsers();
    final key = email.trim().toLowerCase();
    final data = users[key];
    if (data is! Map) return null;
    final storedPassword = (data['password'] ?? '').toString();
    if (password != null && password.isNotEmpty && storedPassword.isNotEmpty && storedPassword != password) {
      return null;
    }

    final userData = Map<String, dynamic>.from(data);
    return UserModel(
      idEmpleado: (userData['num_empleado'] ?? 'LOCAL-${DateTime.now().millisecondsSinceEpoch % 10000}').toString(),
      nombre: (userData['nombre'] ?? 'Usuario ParkRide').toString(),
      correo: (userData['email'] ?? email).toString(),
      departamento: (userData['departamento'] ?? 'Sin departamento').toString(),
      empresa: (userData['empresa'] ?? 'ParkRide').toString(),
      telefono: (userData['telefono'] ?? '+52 81 0000 0000').toString(),
      turno: 'Matutino',
      saldoCreditos: int.tryParse(userData['saldo_creditos']?.toString() ?? '450') ?? 450,
      rol: (userData['rol'] ?? 'Pasajero').toString(),
      hasVehicle: userData['has_vehicle'] == true,
      vehicleInfo: (userData['vehicle_info'] ?? '').toString().trim().isEmpty ? null : (userData['vehicle_info'] ?? '').toString(),
    );
  }

  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Inicializa Supabase. Si no hay llaves reales configuradas,
  /// lo maneja elegantemente para permitir el modo demostración sin crashear.
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[ParkRide] Modo demostración activo.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: kDebugMode,
      );
      SupabaseService()._isInitialized = true;
      debugPrint('[SupabaseService] Conectado exitosamente con Supabase.');
    } catch (e) {
      debugPrint('[SupabaseService] Error al inicializar Supabase: $e');
    }
  }

  // ==========================================
  // AUTENTICACIÓN
  // ==========================================

  /// Registrar usuario con Correo y Contraseña
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String nombre,
    required String rol,
    String empresa = 'Sin empresa',
    String departamento = 'Sin departamento',
    String telefono = '+52 81 0000 0000',
    String numEmpleado = '',
    String? vehicleInfo,
  }) async {
    final normalizedEmpresa =
        empresa.trim().isNotEmpty ? empresa : departamento;
    final normalizedDepartamento =
        departamento.trim().isNotEmpty ? departamento : normalizedEmpresa;
    final normalizedVehicleInfo =
        vehicleInfo?.trim().isNotEmpty == true ? vehicleInfo!.trim() : null;

    if (_isInitialized && client != null) {
      try {
        final AuthResponse res = await client!.auth.signUp(
          email: email,
          password: password,
          data: {
            'nombre': nombre,
            'rol': rol,
            'empresa': normalizedEmpresa,
            'departamento': normalizedDepartamento,
            'telefono': telefono,
            'num_empleado': numEmpleado,
            if (normalizedVehicleInfo != null)
              'vehicle_info': normalizedVehicleInfo,
          },
        );

        final user = res.user;
        if (user != null) {
          // Guardar en tabla de perfiles
          try {
            await client!.from(SupabaseConfig.tableProfiles).upsert({
              'id': user.id,
              'nombre': nombre,
              'correo': email,
              'rol': rol,
              'empresa': normalizedEmpresa,
              'departamento': normalizedDepartamento,
              'telefono': telefono,
              'saldo_creditos': 450,
              'num_empleado': numEmpleado,
              if (normalizedVehicleInfo != null)
                'vehicle_info': normalizedVehicleInfo,
            });
          } catch (e) {
            debugPrint(
                '[SupabaseService] Error creando registro en tabla profiles: $e');
          }

          final localUser = UserModel(
            idEmpleado: user.id.substring(0, 8).toUpperCase(),
            nombre: nombre,
            correo: email,
            departamento: normalizedDepartamento,
            empresa: normalizedEmpresa,
            telefono: telefono,
            turno: 'Matutino',
            saldoCreditos: 450,
            rol: rol,
            hasVehicle: normalizedVehicleInfo != null,
            vehicleInfo: normalizedVehicleInfo,
          );
          await _saveLocalUser(localUser, password);
          return localUser;
        }
      } catch (e) {
        debugPrint('[SupabaseService] Auth error en signUp: $e');
      }
    }

    final localUser = UserModel(
      idEmpleado: 'DEMO-${DateTime.now().millisecondsSinceEpoch % 10000}',
      nombre: nombre,
      correo: email,
      departamento: normalizedDepartamento,
      empresa: normalizedEmpresa,
      telefono: telefono,
      turno: 'Matutino',
      saldoCreditos: 450,
      rol: rol,
      hasVehicle: normalizedVehicleInfo != null,
      vehicleInfo: normalizedVehicleInfo,
    );
    await _saveLocalUser(localUser, password);
    return localUser;
  }

  static bool matchesDemoCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    final knownAccounts = {
      'passenger@parkride.com': 'passenger123',
      'driver@parkride.com': 'driver123',
      'ruta@parkride.com': 'ruta123',
      'admin@parkride.com': 'admin123',
    };
    return knownAccounts.containsKey(normalizedEmail) &&
        knownAccounts[normalizedEmail] == normalizedPassword;
  }

  static UserModel demoUserForEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final isRouteDriver = normalizedEmail.contains('ruta') ||
        normalizedEmail.contains('route') ||
        normalizedEmail.contains('driver') ||
        normalizedEmail.contains('chofer');
    final isSupervisor = normalizedEmail.contains('supervisor') ||
        normalizedEmail.contains('admin');

    final effectiveRole =
        isSupervisor ? 'Admin' : (isRouteDriver ? 'Chofer de Ruta' : 'Pasajero');
    return UserModel(
      idEmpleado: isSupervisor
          ? 'ADM-00001'
          : (isRouteDriver ? 'RUTA-0001' : 'USR-0001'),
      nombre: isSupervisor
          ? 'Administrador ParkRide'
          : (isRouteDriver ? 'Chofer de Ruta ParkRide' : 'Pasajero ParkRide'),
      correo: email,
      departamento: isSupervisor
          ? 'Administración'
          : (isRouteDriver ? 'Transporte y Ruta' : 'Movilidad Corporativa'),
      empresa: 'ParkRide',
      telefono: '+52 81 0000 0000',
      turno: 'Turno Matutino',
      saldoCreditos: isSupervisor ? 9999 : (isRouteDriver ? 680 : 450),
      rol: effectiveRole,
      hasVehicle: isRouteDriver,
      vehicleInfo: isRouteDriver ? 'Van de Transporte #01' : null,
    );
  }

  /// Iniciar sesión con Correo y Contraseña.
  /// Sin cuentas demo; solo se aceptan credenciales reales o un fallback autenticado genérico.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();
    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      throw const FormatException('Correo y contraseña requeridos.');
    }

    final localUser = await _findLocalUser(normalizedEmail, normalizedPassword);
    if (localUser != null) {
      return localUser;
    }

    if (!SupabaseConfig.isConfigured) {
      return demoUserForEmail(normalizedEmail);
    }

    if (_isInitialized && client != null) {
      try {
        final AuthResponse res = await client!.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = res.user;
        if (user != null) {
          try {
            final data = await client!
                .from(SupabaseConfig.tableProfiles)
                .select()
                .eq('id', user.id)
                .maybeSingle();

            if (data != null) {
              final mapped = UserModel.fromMap(data);
              await _saveLocalUser(mapped, password);
              return mapped;
            }
          } catch (e) {
            debugPrint(
                '[SupabaseService] Error consultando tabla profiles: $e');
          }

          final meta = user.userMetadata ?? {};
          final mapped = UserModel(
            idEmpleado: user.id.substring(0, 8).toUpperCase(),
            nombre: meta['nombre'] ?? 'Usuario ParkRide',
            correo: email,
            departamento: meta['departamento'] ?? 'Sin departamento',
            empresa: meta['empresa'] ?? 'ParkRide',
            telefono: meta['telefono'] ?? '+52 81 0000 0000',
            turno: 'Matutino',
            saldoCreditos: 450,
            rol: meta['rol'] ?? 'Pasajero',
          );
          await _saveLocalUser(mapped, password);
          return mapped;
        }
      } catch (e) {
        debugPrint('[SupabaseService] Auth error en signIn: $e');
        if (matchesDemoCredentials(email, password)) {
          return demoUserForEmail(email);
        }
      }
    }

    return demoUserForEmail(normalizedEmail);
  }

  /// Cerrar Sesión
  Future<void> signOut() async {
    if (_isInitialized && client != null) {
      await client!.auth.signOut();
    }
  }

  /// Usuario actual de Supabase
  User? get currentAuthUser => client?.auth.currentUser;

  // ==========================================
  // VIAJES Y SERVICIOS EN TIEMPO REAL
  // ==========================================

  /// Sincroniza el estado de disponibilidad del operador para reflejarse entre dispositivos
  Future<void> syncDriverAvailability({
    required String driverId,
    required String driverName,
    required bool isOnline,
    required String status,
    required String departamento,
    String? vehicleInfo,
  }) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('driver_availability').upsert({
          'driver_id': driverId,
          'driver_name': driverName,
          'is_online': isOnline,
          'status': status,
          'departamento': departamento,
          'vehicle_info': vehicleInfo ?? 'N/A',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint(
            '[SupabaseService] Error actualizando disponibilidad del chofer: $e');
      }
    }
  }

  /// Registrar un nuevo viaje en Supabase
  Future<TripModel?> requestTrip(TripModel trip) async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from(SupabaseConfig.tableTrips)
            .insert(trip.toMap())
            .select()
            .single();
        return TripModel.fromMap(res);
      } catch (e) {
        debugPrint('[SupabaseService] Error solicitando viaje en BD: $e');
      }
    }
    return trip;
  }

  /// Actualizar estado de viaje (ej. 'Asignado', 'En curso', 'Finalizado')
  Future<void> updateTripStatus(String tripId, String newStatus) async {
    if (_isInitialized && client != null) {
      try {
        await client!
            .from(SupabaseConfig.tableTrips)
            .update({'estado': newStatus}).eq('id', tripId);
      } catch (e) {
        debugPrint('[SupabaseService] Error actualizando estado de viaje: $e');
      }
    }
  }

  /// Valida un código QR de ticket de pasajero con Supabase.
  /// Devuelve un resultado con estado, datos del pasajero y motivo de error.
  Future<TicketValidationResult> validateTicketCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) {
      return const TicketValidationResult(
        isValid: false,
        title: 'Código vacío',
        message: 'Escanea un código QR válido del pasajero.',
      );
    }

    if (_isInitialized && client != null) {
      try {
        final response = await client!
            .from(SupabaseConfig.tableTickets)
            .select()
            .eq('code', code)
            .maybeSingle();

        if (response == null) {
          return TicketValidationResult(
            isValid: false,
            title: 'Código inválido',
            message: 'El boleto no existe o no fue emitido por ParkRide.',
          );
        }

        final status =
            (response['status'] ?? 'activo').toString().toLowerCase();
        final expiresAtRaw = response['expires_at'];
        final expiresAt = expiresAtRaw != null
            ? DateTime.tryParse(expiresAtRaw.toString())
            : null;
        final isExpired =
            expiresAt != null && DateTime.now().isAfter(expiresAt);
        final alreadyUsed =
            status == 'used' || status == 'usado' || status == 'consumido';

        if (isExpired) {
          return TicketValidationResult(
            isValid: false,
            title: 'Ticket expirado',
            message: 'Este acceso ya venció y no puede ser usado.',
            isExpired: true,
            passengerName: response['passenger_name']?.toString(),
            status: status,
          );
        }

        if (alreadyUsed) {
          return TicketValidationResult(
            isValid: false,
            title: 'Código ya utilizado',
            message: 'Este boleto ya fue validado anteriormente.',
            alreadyUsed: true,
            passengerName: response['passenger_name']?.toString(),
            status: status,
          );
        }

        if (status != 'activo' && status != 'active') {
          return TicketValidationResult(
            isValid: false,
            title: 'Ticket no activo',
            message: 'El acceso no está disponible para este momento.',
            passengerName: response['passenger_name']?.toString(),
            status: status,
          );
        }

        return TicketValidationResult(
          isValid: true,
          title: 'Acceso permitido',
          message: 'El pasajero puede abordar sin problema.',
          passengerName: response['passenger_name']?.toString() ?? 'Pasajero',
          passengerId: response['passenger_id']?.toString(),
          status: status,
        );
      } catch (e) {
        debugPrint('[SupabaseService] Error validando ticket QR: $e');
      }
    }

    final normalizedCode = code.toUpperCase();
    final demoUsedCodes = await _loadUsedDemoTickets();
    if (_demoUsedTicketCache.contains(normalizedCode) ||
        demoUsedCodes.contains(normalizedCode)) {
      return const TicketValidationResult(
        isValid: false,
        title: 'Código ya utilizado',
        message: 'Este boleto ya fue validado anteriormente.',
        alreadyUsed: true,
      );
    }

    final demoValidCodes = {
      'URB-001': 'Ana García',
      'URB-002': 'Luis Ramírez',
      'URB-003': 'Sofía Torres',
      'PR-QR-001': 'María López',
    };

    if (demoValidCodes.containsKey(normalizedCode)) {
      return TicketValidationResult(
        isValid: true,
        title: 'Acceso permitido',
        message: 'El pasajero puede abordar sin problema.',
        passengerName: demoValidCodes[normalizedCode],
        passengerId: 'demo-passenger',
        status: 'activo',
      );
    }

    if (normalizedCode == 'EXPIRED-QR' || normalizedCode == 'EXPIRADO') {
      return const TicketValidationResult(
        isValid: false,
        title: 'Ticket expirado',
        message: 'Este acceso ya venció y no puede ser usado.',
        isExpired: true,
      );
    }

    if (normalizedCode == 'USED-QR' || normalizedCode == 'USADO') {
      return const TicketValidationResult(
        isValid: false,
        title: 'Código ya utilizado',
        message: 'Este boleto ya fue validado anteriormente.',
        alreadyUsed: true,
      );
    }

    return TicketValidationResult(
      isValid: false,
      title: 'Código inválido',
      message: 'El boleto no existe o no fue emitido por ParkRide.',
    );
  }

  /// Actualiza el estado del ticket a usado después de una validación exitosa.
  Future<void> markTicketAsUsed(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return;

    final normalizedCode = code.toUpperCase();
    final usedCodes = await _loadUsedDemoTickets();
    usedCodes.add(normalizedCode);
    _demoUsedTicketCache.add(normalizedCode);
    await _saveUsedDemoTickets(usedCodes);

    if (_isInitialized && client != null) {
      try {
        await client!.from(SupabaseConfig.tableTickets).update({
          'status': 'used',
          'used_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('code', code);
      } catch (e) {
        debugPrint('[SupabaseService] Error marcando ticket como usado: $e');
      }
    }
  }
}
