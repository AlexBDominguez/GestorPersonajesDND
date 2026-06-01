import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/services/auth/auth_service.dart';
import 'package:gestor_personajes_dnd/services/storage/token_storage.dart';

class ApiClient{
  /// Se llama cuando el servidor devuelve 401 o 403 — indica a la app que cierre sesión.
  static void Function()? onSessionExpired;
  final TokenStorage _tokenStorage;
  final AuthService _authService;
  static Future<bool>? _refreshInFlight;

  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        _authService = AuthService();

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

  bool _canAttemptRefresh(String path) {
    return path != ApiConfig.loginPath &&
        path != ApiConfig.refreshPath &&
        path != ApiConfig.logoutPath;
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    final refreshFuture = () async {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      try {
        final auth = await _authService.refresh(refreshToken);
        await _tokenStorage.saveSession(
          accessToken: auth.token,
          username: auth.username,
          role: auth.role,
        );
        await _tokenStorage.saveRefreshToken(auth.refreshToken);
        return true;
      } catch (_) {
        return false;
      }
    }();

    _refreshInFlight = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<http.Response> _sendWithRefresh(
    String path,
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    final initial = await send(await _buildHeaders());
    if (initial.statusCode != 401 || !_canAttemptRefresh(path)) {
      if (initial.statusCode == 401) {
        ApiClient.onSessionExpired?.call();
      }
      return initial;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      ApiClient.onSessionExpired?.call();
      return initial;
    }

    final retry = await send(await _buildHeaders());
    if (retry.statusCode == 401) {
      ApiClient.onSessionExpired?.call();
    }
    return retry;
  }

  Future<http.Response> get(String path) async {
    return _sendWithRefresh(
      path,
      (headers) => http.get(_uri(path), headers: headers),
    );
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final encodedBody = body == null ? null : jsonEncode(body);
    return _sendWithRefresh(
      path,
      (headers) => http.post(
        _uri(path),
        headers: headers,
        body: encodedBody,
      ),
    );
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final encodedBody = body == null ? null : jsonEncode(body);
    return _sendWithRefresh(
      path,
      (headers) => http.put(
        _uri(path),
        headers: headers,
        body: encodedBody,
      ),
    );
  }

  Future<http.Response> delete(String path) async {
    return _sendWithRefresh(
      path,
      (headers) => http.delete(_uri(path), headers: headers),
    );
  }

  Future<http.Response> patch(String path, {Object? body}) async {
    final encodedBody = body == null ? null : jsonEncode(body);
    return _sendWithRefresh(
      path,
      (headers) => http.patch(
        _uri(path),
        headers: headers,
        body: encodedBody,
      ),
    );
  }
}