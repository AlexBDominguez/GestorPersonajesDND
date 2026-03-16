import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/auth/auth_response.dart';
import 'package:frontend/models/auth/login_request.dart';

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async{
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginPath}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200){
      final Map<String, dynamic> json = jsonDecode(response.body);
      return AuthResponse.fromJson(json);
    }

    if(response.statusCode == 401){
      throw Exception('Invalid username or password');
    }

    throw Exception('Error login (${response.statusCode}): ${response.body}');
  }
}