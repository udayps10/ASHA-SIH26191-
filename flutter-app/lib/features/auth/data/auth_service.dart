import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';

class AuthService {
  String? _token;
  String? _uid;
  String? _name;
  String? _email;
  String? _role;
  bool? _approved;

  String? get token => _token;
  String? get uid => _uid;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  bool? get approved => _approved;
  bool get isLoggedIn => _token != null;

  static const _tokenKey = 'auth_token';
  static const _uidKey = 'auth_uid';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';
  static const _roleKey = 'auth_role';
  static const _approvedKey = 'auth_approved';

  AuthService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _uid = prefs.getString(_uidKey);
    _name = prefs.getString(_nameKey);
    _email = prefs.getString(_emailKey);
    _role = prefs.getString(_roleKey);
    _approved = prefs.getBool(_approvedKey);
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(_tokenKey, _token!);
    if (_uid != null) await prefs.setString(_uidKey, _uid!);
    if (_name != null) await prefs.setString(_nameKey, _name!);
    if (_email != null) await prefs.setString(_emailKey, _email!);
    if (_role != null) await prefs.setString(_roleKey, _role!);
    if (_approved != null) await prefs.setBool(_approvedKey, _approved!);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_approvedKey);
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.matchingBaseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _uid = data['uid'];
        _name = data['name'];
        _email = data['email'];
        _role = data['role'];
        _approved = data['approved'];
        await _saveToStorage();
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Registration failed';
      }
    } catch (e) {
      debugPrint('SignUp error: $e');
      return 'Connection error. Please check your connection.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.matchingBaseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _uid = data['uid'];
        _name = data['name'];
        _email = data['email'];
        _role = data['role'];
        _approved = data['approved'];
        await _saveToStorage();
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Login failed';
      }
    } catch (e) {
      debugPrint('SignIn error: $e');
      return 'Connection error. Please check your connection.';
    }
  }

  Future<void> signOut() async {
    _token = null;
    _uid = null;
    _name = null;
    _email = null;
    _role = null;
    _approved = null;
    await _clearStorage();
  }

  Future<bool> tryAutoLogin() async {
    await _loadFromStorage();
    return _token != null;
  }

  Map<String, String> get authHeaders => {
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
}
