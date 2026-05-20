import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'services/http/api_client.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const DndApp());
}

class DndApp extends StatelessWidget {
  const DndApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel()..init(),
      child: MaterialApp(
        title: 'DungeonScroll',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Consumer<AuthViewModel>(
          builder: (context, vm, child) {
            // Register global 401/403 → logout handler
            ApiClient.onSessionExpired = () { vm.logout(); };

            if (!vm.isInitialized) {
              return const _StartupLoadingScreen();
            }

            return vm.isLoggedIn
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}