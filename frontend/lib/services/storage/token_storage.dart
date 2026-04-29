import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _roleKey = 'auth_role';

  Future<void> saveSession({
    required String token,
    required String username,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getToken()    async => (await SharedPreferences.getInstance()).getString(_tokenKey);
  Future<String?> getUsername() async => (await SharedPreferences.getInstance()).getString(_usernameKey);
  Future<String?> getRole()     async => (await SharedPreferences.getInstance()).getString(_roleKey);

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
  }
}