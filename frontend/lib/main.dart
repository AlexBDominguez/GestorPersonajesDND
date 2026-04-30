import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'services/http/api_client.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            return vm.isLoggedIn
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}