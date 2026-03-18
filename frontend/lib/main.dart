import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: 'D&D App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthViewModel>(
          builder: (context, vm, child) {
            if (!vm.isLoggedIn) {
              return const LoginScreen();
            }
            return const DashboardScreen();
          },
        ),
      ),
    );
  }
}