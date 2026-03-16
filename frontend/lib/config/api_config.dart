class ApiConfig {
   /// URL base del backend.
  /// - Android emulator: http://10.0.2.2:8081
  /// - iOS simulator: http://localhost:8081
  /// - Device físico: http://<IP-DE-TU-PC>:8081
  static const String baseUrl = 'http://localhost:8081';

  //Prefijo para las rutas de la API
  static const String apiPrefix = '/api';

  /// Auth
  static const String loginPath = '$apiPrefix/auth/login';

  ///Characters
  static const String charactersPath = '$apiPrefix/characters';
}