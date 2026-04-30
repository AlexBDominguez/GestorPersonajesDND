import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/services/storage/token_storage.dart';

class ApiClient{
  /// Called when the server returns 401 or 403 — signals the app to log out.
  static void Function()? onSessionExpired;
  final TokenStorage _tokenStorage;

  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage();

  Future<Map<String, String>> _buildHeaders({bool jsonBody = true}) async {
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

  http.Response _check(http.Response res) {
    if (res.statusCode == 401 || res.statusCode == 403) {
      ApiClient.onSessionExpired?.call();
    }
    return res;
  }

  Future<http.Response> get(String path) async {
    return _check(await http.get(_uri(path), headers: await _buildHeaders()));
  }

  Future<http.Response> post(String path, {Object? body}) async {
    return _check(await http.post(
      _uri(path),
      headers: await _buildHeaders(),
      body: body == null ? null : jsonEncode(body),
    ));
  }

  Future<http.Response> put(String path, {Object? body}) async {
    return _check(await http.put(
      _uri(path),
      headers: await _buildHeaders(),
      body: body == null ? null : jsonEncode(body),
    ));
  }

  Future<http.Response> delete(String path) async {
    return _check(await http.delete(_uri(path), headers: await _buildHeaders()));
  }

  Future<http.Response> patch(String path, {Object? body}) async {
    return _check(await http.patch(
      _uri(path),
      headers: await _buildHeaders(),
      body: body == null ? null : jsonEncode(body),
    ));
  }
}