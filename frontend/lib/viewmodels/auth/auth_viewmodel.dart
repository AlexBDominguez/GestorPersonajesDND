import 'package:flutter/foundation.dart';
import 'package:gestor_personajes_dnd/models/auth/login_request.dart';
import 'package:gestor_personajes_dnd/services/auth/auth_service.dart';
import 'package:gestor_personajes_dnd/services/storage/local_cache_service.dart';
import 'package:gestor_personajes_dnd/services/storage/token_storage.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService  _authService;
  final TokenStorage _tokenStorage;

  AuthViewModel({AuthService? authService, TokenStorage? tokenStorage})
      : _authService    = authService   ?? AuthService(),
        _tokenStorage   = tokenStorage  ?? TokenStorage();

  bool    _isLoading     = false;
  bool    _isInitialized = false;
  String? _errorMessage;
  bool    _isLoggedIn    = false;
  bool    _isAdmin       = false;
  String  _username      = '';

  bool    get isLoading       => _isLoading;
  bool    get isInitialized   => _isInitialized;
  String? get errorMessage    => _errorMessage;
  bool    get isLoggedIn      => _isLoggedIn;
  bool    get isAdmin         => _isAdmin;
  String  get currentUsername => _username;

  // ── Init (cold-start auto-login via stored refresh token) ─────────────────

  Future<void> init() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        // No persisted session — clear any stale access token and show login.
        await _tokenStorage.clearSession();
      } else {
        // Exchange refresh token for a fresh access token.
        try {
          final auth = await _authService.refresh(refreshToken,
              deviceInfo: _deviceInfo());
          await _tokenStorage.saveSession(
            accessToken: auth.token,
            username:    auth.username,
            role:        auth.role,
          );
          // Persist the rotated refresh token (same persist flag as before).
          await _tokenStorage.saveRefreshToken(auth.refreshToken, persist: true);
          _isLoggedIn = true;
          _username   = auth.username;
          _isAdmin    = auth.role == 'ADMIN';
        } catch (e) {
          // Refresh token expired / revoked — force a fresh login.
          await _tokenStorage.clearSession();
          _isLoggedIn = false;
          if (kDebugMode) print('[AuthViewModel.init] refresh failed: $e');
        }
      }
    } catch (e) {
      _isLoggedIn = false;
      if (kDebugMode) print('[AuthViewModel.init] error: $e');
    } finally {
      _isInitialized = true;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final auth = await _authService.login(
          LoginRequest(username: username, password: password));

      await _tokenStorage.saveSession(
        accessToken: auth.token,
        username:    auth.username,
        role:        auth.role,
      );
      // Save refresh token; persist to secure storage only when rememberMe=true.
      await _tokenStorage.saveRefreshToken(
        auth.refreshToken,
        persist: rememberMe,
      );

      _isLoggedIn = true;
      _username   = auth.username;
      _isAdmin    = auth.role == 'ADMIN';
    } catch (e) {
      final msg = e.toString();
      _setError(msg.startsWith('Exception: ') ? msg.substring(11) : msg);
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Best-effort server-side revocation (fire and forget).
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      _authService.logout(refreshToken).catchError((_) {});
    }
    await Future.wait([
      _tokenStorage.clearSession(),
      LocalCacheService.clearAll(),
    ]);
    _isLoggedIn = false;
    _isAdmin    = false;
    _username   = '';
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? v) { _errorMessage = v; notifyListeners(); }

  String _deviceInfo() {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.iOS)     return 'iOS';
    return 'Unknown';
  }
}
