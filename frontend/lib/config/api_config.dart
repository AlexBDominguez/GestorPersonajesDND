class ApiConfig {
   /// URL base del backend.
  /// - Android emulator: http://10.0.2.2:8081
  /// - iOS simulator: http://localhost:8081
  /// - Device físico: http://<IP-DE-TU-PC>:8081
  /// Chrome emulador:
  static const String baseUrl = 'http://localhost:8081';
  //static const String baseUrl = 'http://10.0.2.2:8081';
  ///PRODUCCIÓN (VPS) - descomenta esta línea y comenta la de arriba para el APK
  // static const String baseurl = 'http://178.104.94.11:8081';

  //Prefijo para las rutas de la API
  static const String apiPrefix = '/api';

  /// Auth
  static const String loginPath = '$apiPrefix/auth/login';

  ///Characters
  static const String charactersPath = '$apiPrefix/characters';

  // Reference Data (Wizard)
  static const String racesPath = '$apiPrefix/races';
  static const String classesPath = '$apiPrefix/classes';
  static const String backgroundsPath = '$apiPrefix/backgrounds';  
  
}