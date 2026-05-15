import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey    = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _roleKey     = 'auth_role';
  static const _refreshKey  = 'auth_refresh_token';

  // In-memory refresh token cache (shared across all instances via static field).
  static String? _memRefreshToken;

  // Tracks whether the refresh token was persisted to secure storage
  // so that rotation knows whether to persist the replacement.
  static bool _refreshTokenPersisted = false;

  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Access token + non-sensitive metadata (SharedPreferences) ─────────────

  Future<void> saveSession({
    required String accessToken,
    required String username,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey,    accessToken);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey,     role);
  }

  Future<void> updateAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken()    async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);
  Future<String?> getUsername() async =>
      (await SharedPreferences.getInstance()).getString(_usernameKey);
  Future<String?> getRole()     async =>
      (await SharedPreferences.getInstance()).getString(_roleKey);

  // ── Refresh token (secure storage + memory cache) ─────────────────────────

  /// Saves the refresh token.
  /// [persist] = true  → also write to encrypted secure storage (rememberMe=true).
  /// [persist] = null  → reuse whatever the previous decision was (used by rotation).
  Future<void> saveRefreshToken(String token, {bool? persist}) async {
    _memRefreshToken = token;
    final shouldPersist = persist ?? _refreshTokenPersisted;
    if (shouldPersist) {
      _refreshTokenPersisted = true;
      await _secure.write(key: _refreshKey, value: token);
    }
  }

  Future<String?> getRefreshToken() async {
    if (_memRefreshToken != null) return _memRefreshToken;
    // Cold start: try to load persisted value
    final persisted = await _secure.read(key: _refreshKey);
    if (persisted != null) {
      _memRefreshToken       = persisted;
      _refreshTokenPersisted = true;
    }
    return persisted;
  }

  // ── Full clear ─────────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    _memRefreshToken       = null;
    _refreshTokenPersisted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
    await _secure.delete(key: _refreshKey);
  }
}
