import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Usuario'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              onSubmitted: (_) => _onLoginPressed(context),
            ),
            const SizedBox(height: 16),

            if (vm.errorMessage != null) ...[
              Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => _onLoginPressed(context),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed(BuildContext context) async {
    final vm = context.read<AuthViewModel>();
    await vm.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (vm.isLoggedIn && context.mounted) {
      // Luego lo cambiaremos por navegación real a Dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login OK')),
      );
    }
  }
}