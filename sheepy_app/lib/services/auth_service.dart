import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../models/user_stats.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  Future<void> register(String username, String email, String password) async {
    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/auth/register');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al registrar usuario');
    }
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/auth/login');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserStats?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return UserStats.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  Future<UserStats> fetchMe() async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiConfig.bibleBaseUrl}/api/users/me');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(data));
      return UserStats.fromJson(data);
    } else {
      throw Exception('Error al obtener perfil');
    }
  }
}
