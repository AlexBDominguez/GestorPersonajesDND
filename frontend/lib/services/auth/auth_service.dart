import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/auth/auth_response.dart';
import 'package:gestor_personajes_dnd/models/auth/login_request.dart';

class AuthService {
  // ── Login ─────────────────────────────────────────────────────────────────

  Future<AuthResponse> login(LoginRequest request) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginPath}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Wrong credentials. Try again.');
      }
      if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      }
      throw Exception('Unexpected error (${response.statusCode}).');
    } on SocketException {
      throw Exception('Cannot reach the server. Check your network connection.');
    } on TimeoutException {
      throw Exception('Connection timed out. The server may be down.');
    } on http.ClientException {
      throw Exception('Cannot reach the server. Check your network connection.');
    } on Exception {
      rethrow;
    }
  }

  // ── Refresh ───────────────────────────────────────────────────────────────

  Future<AuthResponse> refresh(String refreshToken, {String deviceInfo = ''}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshPath}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken, 'deviceInfo': deviceInfo}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Session expired. Please log in again.');
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout(String refreshToken) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutPath}');
    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Best-effort: server-side revocation is nice to have but client
      // clears local state regardless.
    }
  }
}
