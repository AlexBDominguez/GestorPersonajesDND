import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'l10n/app_strings.dart';
import 'services/http/api_client.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'viewmodels/locale_viewmodel.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeVm = LocaleViewModel();
  await localeVm.init();
  runApp(DndApp(localeVm: localeVm));
}

class DndApp extends StatelessWidget {
  final LocaleViewModel localeVm;
  const DndApp({super.key, required this.localeVm});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleViewModel>.value(value: localeVm),
        ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
      ],
      child: Consumer<LocaleViewModel>(
        builder: (_, lVm, __) => MaterialApp(
          title: 'DungeonScroll',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: lVm.locale,
          supportedLocales: const [Locale('en'), Locale('es'), Locale('gl')],
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<AuthViewModel>(
            builder: (context, vm, child) {
              ApiClient.onSessionExpired = () { vm.logout(); };
              return vm.isLoggedIn
                  ? const DashboardScreen()
                  : const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}