import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth/auth_viewmodel.dart';
import 'views/screens/login_screen.dart';

void main() {
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
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    if(!vm.isLoggedIn) {
      return const LoginScreen();
    }
    return const DashboardScreen();
    }  
}