import 'package:flutter/foundation.dart';
import 'package:gestor_personajes_dnd/models/auth/login_request.dart';
import 'package:gestor_personajes_dnd/services/auth/auth_service.dart';
import 'package:gestor_personajes_dnd/services/storage/token_storage.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;


  AuthViewModel({
    AuthService? authService,
    TokenStorage? tokenStorage,
  }) : _authService = authService ?? AuthService(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> init() async {
    try {
      final token = await _tokenStorage.getToken();
      _isLoggedIn = token != null && token.isNotEmpty;
    } catch (e) {
      // Si hay error al leer el token, asumimos que no está logueado
      _isLoggedIn = false;
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
    }
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try{
      final auth = await _authService.login(
        LoginRequest(username: username, password: password),
      );
      
      await _tokenStorage.saveSession(
        token: auth.token,
        username: auth.username,
        email: auth.email,
      );

      _isLoggedIn = true;
    } catch (e) {
      final msg = e.toString();
      _setErrorMessage(msg.startsWith('Exception: ') ? msg.substring(11) : msg);
      _isLoggedIn = false;
    }finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async{
    await _tokenStorage.clearSession();
    _isLoggedIn = false;
    notifyListeners();
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }
}