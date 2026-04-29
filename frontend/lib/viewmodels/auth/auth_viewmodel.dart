import 'package:flutter/foundation.dart';
import 'package:gestor_personajes_dnd/models/auth/login_request.dart';
import 'package:gestor_personajes_dnd/services/auth/auth_service.dart';
import 'package:gestor_personajes_dnd/services/storage/token_storage.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService   _authService;
  final TokenStorage  _tokenStorage;

  AuthViewModel({AuthService? authService, TokenStorage? tokenStorage})
      : _authService    = authService   ?? AuthService(),
        _tokenStorage   = tokenStorage  ?? TokenStorage();

  bool    _isLoading    = false;
  String? _errorMessage;
  bool    _isLoggedIn   = false;
  bool    _isAdmin      = false;
  String  _username     = '';

  bool    get isLoading       => _isLoading;
  String? get errorMessage    => _errorMessage;
  bool    get isLoggedIn      => _isLoggedIn;
  bool    get isAdmin         => _isAdmin;
  String  get currentUsername => _username;

  Future<void> init() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
        _username   = await _tokenStorage.getUsername() ?? '';
        final storedRole = await _tokenStorage.getRole();
        _isAdmin    = storedRole == 'ADMIN';
        if (kDebugMode) print('[AuthViewModel.init] storedRole=$storedRole  _isAdmin=$_isAdmin');
      }
    } catch (e) {
      _isLoggedIn = false;
      if (kDebugMode) print('Error initializing auth: $e');
    }
    notifyListeners();
  }

  Future<void> login({required String username, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      final auth = await _authService.login(
          LoginRequest(username: username, password: password));

      await _tokenStorage.saveSession(
        token:    auth.token,
        username: auth.username,
        role:     auth.role,
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

  Future<void> logout() async {
    await _tokenStorage.clearSession();
    _isLoggedIn = false;
    _isAdmin    = false;
    _username   = '';
    notifyListeners();
  }

  // Actualizar username localmente tras cambiarlo
  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? v) { _errorMessage = v; notifyListeners(); }
}