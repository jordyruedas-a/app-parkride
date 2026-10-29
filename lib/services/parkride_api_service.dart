import 'dart:convert';
import 'package:http/http.dart' as http;

class ParkRideApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('Registro fallido: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 400) {
      throw Exception('Credenciales inválidas');
    }

    return jsonDecode(response.body);
  }

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode >= 400) {
      throw Exception('No se pudo consultar usuarios');
    }
    final decoded = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(decoded is List ? decoded : []);
  }
}
