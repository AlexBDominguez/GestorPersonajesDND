import 'package:flutter/foundation.dart';

class ApiConfig {
  /// En producción web (build de release), URL vacía → Nginx hace proxy a /api/.
  /// En desarrollo web (flutter run) y en móvil, URL absoluta del VPS.
  /// - Android emulator: http://10.0.2.2:8081
  /// - Device físico / APK producción: http://178.104.94.11:8081
  static String get baseUrl {
    if (kIsWeb && kReleaseMode) return '';
    return 'http://178.104.94.11:8081';
  }

  //Prefijo para las rutas de la API
  static const String apiPrefix = '/api';

  /// Auth
  static const String loginPath    = '$apiPrefix/auth/login';
  static const String refreshPath   = '$apiPrefix/auth/refresh';
  static const String logoutPath    = '$apiPrefix/auth/logout';

  ///Characters
  static const String charactersPath = '$apiPrefix/characters';

  // Reference Data (Wizard)
  static const String racesPath = '$apiPrefix/races';
  static const String classesPath = '$apiPrefix/classes';
  static const String backgroundsPath = '$apiPrefix/backgrounds';  
  
}