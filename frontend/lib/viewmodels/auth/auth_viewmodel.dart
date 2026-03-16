import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth/login_request.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/auth/token_storage.dart';

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
    final token = await _tokenStorage.getToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    __setLoading(true);
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
    }catch (e){
      _setErrorMessage(e.toString());
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
}