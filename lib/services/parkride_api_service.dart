import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ParkRideApiException implements Exception {
  final String message;

  const ParkRideApiException(this.message);

  @override
  String toString() => message;
}

class QrTicket {
  final String tripId;
  final String token;
  final DateTime expiresAt;

  const QrTicket({
    required this.tripId,
    required this.token,
    required this.expiresAt,
  });
}

class ParkRideApiService {
  ParkRideApiService._();

  static final ParkRideApiService instance = ParkRideApiService._();
  static const _requestTimeout = Duration(seconds: 12);

  // Use --dart-define=PARKRIDE_API_URL=<url> for a physical device or production.
  static const baseUrl = String.fromEnvironment(
    'PARKRIDE_API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  String? _accessToken;

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final response = await _request('POST', '/auth/register', body: payload);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final decoded = await _loginWithResponse(email, password);
    return Map<String, dynamic>.from(decoded['user'] as Map);
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    return instance._loginWithResponse(email, password);
  }

  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> payload) async {
    return instance.register(payload);
  }

  Future<Map<String, dynamic>> _loginWithResponse(
      String email, String password) async {
    final response = await _request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final decoded = _decodeObject(response);
    final token = decoded['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ParkRideApiException(
          'El servidor no devolvió una sesión válida.');
    }
    _accessToken = token;
    return decoded;
  }

  Future<void> logout() async {
    _accessToken = null;
  }

  Future<List<Map<String, dynamic>>> getRoutes() async {
    final response = await _request('GET', '/routes', authenticated: true);
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> updateCurrentUser(
      String userId, Map<String, dynamic> payload) async {
    final response = await _request(
      'PUT',
      '/users/$userId',
      authenticated: true,
      body: payload,
    );
    return _decodeObject(response);
  }

  Future<QrTicket> createTrip({
    required String routeId,
    required String transportType,
    required String origin,
    required String destination,
    required int creditCost,
  }) async {
    final response = await _request(
      'POST',
      '/trips',
      authenticated: true,
      body: {
        'route_id': routeId,
        'transport_type': transportType,
        'origin': origin,
        'destination': destination,
        'credit_cost': creditCost,
      },
    );
    final decoded = _decodeObject(response);
    return QrTicket(
      tripId: decoded['trip_id'].toString(),
      token: decoded['token'].toString(),
      expiresAt: DateTime.parse(decoded['expires_at'].toString()).toLocal(),
    );
  }

  Future<void> validateQr(String token) async {
    final response = await _request(
      'POST',
      '/qr/validate',
      authenticated: true,
      body: {'token': token},
    );
    final decoded = _decodeObject(response);
    if (decoded['valid'] != true) {
      throw const ParkRideApiException('El QR no pudo ser validado.');
    }
  }

  Future<void> submitReport({
    required String category,
    required String comment,
  }) async {
    await _request(
      'POST',
      '/reports',
      authenticated: true,
      body: {'category': category, 'comment': comment},
    );
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    final response = await _request('GET', '/reports', authenticated: true);
    return _decodeList(response);
  }

  Future<void> resolveReport(String reportId) async {
    await _request('POST', '/reports/$reportId/resolve', authenticated: true);
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final uri = Uri.parse('$baseUrl$path');
    late final http.Response response;
    try {
      response = switch (method) {
        'GET' => await http.get(uri, headers: headers).timeout(_requestTimeout),
        'POST' => await http
            .post(uri,
                headers: headers, body: body == null ? null : jsonEncode(body))
            .timeout(_requestTimeout),
        'PUT' => await http
            .put(uri,
                headers: headers, body: body == null ? null : jsonEncode(body))
            .timeout(_requestTimeout),
        _ => throw ArgumentError.value(
            method, 'method', 'Unsupported HTTP method'),
      };
    } on TimeoutException {
      throw const ParkRideApiException(
        'El servidor no respondió en 12 segundos. Verifica tu conexión y la URL de la API.',
      );
    }
    if (response.statusCode >= 400) {
      throw ParkRideApiException(_errorMessage(response));
    }
    return response;
  }

  static Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const ParkRideApiException('Respuesta inválida del servidor.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static List<Map<String, dynamic>> _decodeList(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ParkRideApiException('Respuesta inválida del servidor.');
    }
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } on FormatException {
      // The response body is included below when it is not JSON.
    }
    return response.body.isEmpty
        ? 'Error HTTP ${response.statusCode}'
        : response.body;
  }
}
