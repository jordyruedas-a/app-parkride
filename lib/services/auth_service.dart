import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/parkride_constants.dart';
import '../models/user_profile.dart';
import 'parkride_api_service.dart';

class AuthService extends ChangeNotifier {
  UserProfile? _user;
  bool _loading = false;
  String? _accessToken;

  UserProfile? get user => _user;
  bool get loading => _loading;
  String? get accessToken => _accessToken;

  Future<void> signIn({required String email, required String password}) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ParkRideApiService.loginUser(email, password);
      _accessToken = response['access_token'];

      final userMap = response['user'];
      _user = UserProfile(
        id: userMap['id'] ?? '',
        email: userMap['email'] ?? '',
        name: userMap['name'] ?? '',
        role: userMap['role'] ?? 'passenger',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('parkride_token', _accessToken ?? '');
      await prefs.setString(
          'parkride_user',
          jsonEncode({
            'id': _user?.id,
            'email': _user?.email,
            'name': _user?.name,
            'role': _user?.role,
          }));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? company,
    String? department,
    String? employeeNumber,
    String? phone,
    String? shift,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final payload = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (company != null && company.trim().isNotEmpty) 'company': company,
        if (department != null && department.trim().isNotEmpty)
          'department': department,
        if (employeeNumber != null && employeeNumber.trim().isNotEmpty)
          'employee_number': employeeNumber,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
        if (shift != null && shift.trim().isNotEmpty) 'shift': shift,
      };

      final response = await ParkRideApiService.registerUser(payload);
      _user = UserProfile.fromJson(response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'parkride_user',
          jsonEncode({
            'id': _user?.id,
            'email': _user?.email,
            'name': _user?.name,
            'role': _user?.role,
          }));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _user = null;
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parkride_token');
    await prefs.remove('parkride_user');
    notifyListeners();
  }

  static List<UserSeed> get seedUsers => ParkRideSeedData.seedUsers();
}
