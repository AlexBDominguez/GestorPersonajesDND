import 'package:flutter/foundation.dart';
import 'package:gestor_personajes_dnd/models/auth/auth_response.dart';
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

  // ── Inicialización (auto-login en arranque en frío mediante refresh token guardado) ──

  Future<void> init() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        // Sin sesión persistida — limpiar cualquier access token caducado y mostrar el login.
        await _tokenStorage.clearSession();
      } else {
          // Intercambiar el refresh token por un nuevo access token.
        try {
          final auth = await _authService.refresh(refreshToken,
              deviceInfo: _deviceInfo());
          await _tokenStorage.saveSession(
            accessToken: auth.token,
            username:    auth.username,
            role:        auth.role,
          );
          // Persistir el refresh token rotado (mismo flag persist que antes).
          await _tokenStorage.saveRefreshToken(auth.refreshToken, persist: true);
          _isLoggedIn = true;
          _username   = auth.username;
          _isAdmin    = auth.role == 'ADMIN';
        } catch (e) {
          // Refresh token caducado / revocado — forzar un nuevo login.
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
      // Guardar el refresh token; persistir en almacenamiento seguro solo cuando rememberMe=true.
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
    // Revocación server-side best-effort (fire and forget).
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

  // ── Change username (#15) ────────────────────────────────────────────────
  // Renombrarse invalida el access token y los refresh tokens ya emitidos (llevan el
  // username viejo, ver el comentario en UserService.changeOwnUsername del backend) --
  // por eso el endpoint devuelve un AuthResponse completo con tokens nuevos, y aquí hay
  // que persistirlos exactamente igual que en login(), no solo actualizar el nombre en
  // memoria (a diferencia del updateUsername() anterior, que no sobrevivía a un reinicio).
  Future<void> applyUsernameChange(AuthResponse auth) async {
    await _tokenStorage.saveSession(
      accessToken: auth.token,
      username:    auth.username,
      role:        auth.role,
    );
    // Reutiliza la decisión de persistencia anterior (rememberMe), igual que la rotación.
    await _tokenStorage.saveRefreshToken(auth.refreshToken, persist: null);

    _username = auth.username;
    _isAdmin  = auth.role == 'ADMIN';
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? v) { _errorMessage = v; notifyListeners(); }

  String _deviceInfo() {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.iOS)     return 'iOS';
    return 'Unknown';
  }
}
