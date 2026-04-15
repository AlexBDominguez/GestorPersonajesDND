import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/auth/auth_response.dart';
import 'package:gestor_personajes_dnd/models/auth/login_request.dart';

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginPath}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return AuthResponse.fromJson(json);
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
}