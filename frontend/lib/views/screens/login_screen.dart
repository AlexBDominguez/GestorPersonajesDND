import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed(AuthViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    await vm.login(
      username:   _usernameCtrl.text.trim(),
      password:   _passwordCtrl.text,
      rememberMe: _rememberMe,
    );    
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.background, AppTheme.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // EMBLEMA O LOGO DE LA APP AQUÍ
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                      color: AppTheme.surface,
                  ),
                  child: const Icon(Icons.shield, size: 52, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('DungeonScroll', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 6),
                  Text('D&D Character Manager', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 48),

                  // Formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your username' : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter your password' : null,
                          onFieldSubmitted: (_) => _onLoginPressed(vm),
                        ),
                        const SizedBox(height: 4),

                        // Remember me
                        CheckboxListTile(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppTheme.primary,
                          checkColor: AppTheme.background,
                          side: const BorderSide(color: AppTheme.textSecondary),
                          title: Text(
                            'Remember me',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Error message
                        if (vm.errorMessage != null)...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.accent),                              
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline, color: AppTheme.accent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(vm.errorMessage!,
                                style: const TextStyle(
                                  color: AppTheme.accent, fontSize: 13)),
                                ),                              
                            ]),
                          ),
                          const SizedBox(height: 16),
                        ],

                        //Botón de login
                        ElevatedButton(
                          onPressed: vm.isLoading ? null : () => _onLoginPressed(vm),
                          child: vm.isLoading
                              ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.background),
                                )
                                : const Text('Login'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Only the Dungeon Master can add new players', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}