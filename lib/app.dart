import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/ecotrack_repository.dart';
import 'data/services/auth_service.dart';
import 'logic/auth_controller.dart';
import 'logic/ecotrack_controller.dart';
import 'logic/navigation_controller.dart';
import 'ui/screens/login/login_screen.dart';
import 'ui/screens/shell/app_shell.dart';
import 'ui/screens/startup/startup_screen.dart';

/// Raiz do aplicativo: injeta os controladores (Provider) e o tema.
class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({
    super.key,
    required this.repository,
    this.authService = const AuthService(),
  });

  final EcoTrackRepository repository;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authService)),
        ChangeNotifierProvider(create: (_) => EcoTrackController(repository)..load()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const RootGate(),
      ),
    );
  }
}

/// Decide a tela: carregando, erro, login ou área autenticada.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EcoTrackController>();
    final isAuthenticated = context.watch<AuthController>().isAuthenticated;

    switch (data.status) {
      case LoadStatus.loading:
        return const StartupLoadingScreen();
      case LoadStatus.error:
        return StartupErrorScreen(
          message: data.errorMessage ?? 'Não foi possível carregar os registros.',
        );
      case LoadStatus.ready:
        return isAuthenticated ? const AppShell() : const LoginScreen();
    }
  }
}
