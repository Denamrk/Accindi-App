import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const AccindiApp());
}

class AccindiApp extends StatelessWidget {
  const AccindiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accindi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: {
        '/': (_) => const _SplashWrapper(),
        '/welcome': (_) => const _WelcomeWrapper(),
        '/register': (_) => const _RegisterWrapper(),
        '/login': (_) => const _LoginWrapper(),
        '/home': (_) => const HomeShell(),
      },
    );
  }
}

class _SplashWrapper extends StatelessWidget {
  const _SplashWrapper();

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onDone: () {
        Navigator.of(context).pushReplacementNamed('/welcome');
      },
    );
  }
}

class _WelcomeWrapper extends StatelessWidget {
  const _WelcomeWrapper();

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(
      onLogin: () => Navigator.of(context).pushNamed('/login'),
      onRegister: () => Navigator.of(context).pushNamed('/register'),
    );
  }
}

class _RegisterWrapper extends StatelessWidget {
  const _RegisterWrapper();

  @override
  Widget build(BuildContext context) {
    return RegistrationScreen(
      onBack: () => Navigator.of(context).pop(),
      onLogin: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }
}

class _LoginWrapper extends StatelessWidget {
  const _LoginWrapper();

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onSuccess: () {
        // After login, go to home (replace all onboarding stack)
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      },
      onForgot: () {
        // TODO: forgot PIN flow
      },
    );
  }
}
