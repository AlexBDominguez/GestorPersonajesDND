import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage/token_storage.dart';

class ApiClient{
  final TokenStorage _tokenStorage;

  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenSotrage ?? TokenStorage();

  Futurez<Map<String, String>> _buildHeaders({bool jsonBody = true}) async {
    final token = await _tokenStorage.getToken();

    final headers = <String, String>{};

    if(jsonBody) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }
    if(token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<http.Response> get(String path) async {
    return http.get(_uri(path), headers: await _buildHeaders());
  }

  Future<http.Response> post(String path, {Object? body}) async {
    return http.post(
      _uri(path),
      headers: await _buildHeaders(),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(String path, {Object? body}) async {
    return http.put(
      _uri(path),
      headers: await _buildHeaders(),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) async {
    return http.delete(_uri(path), headers: await _buildHeaders());
  }
}