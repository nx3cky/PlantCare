import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/crash_reporting.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../shell/main_shell.dart';
import 'data/auth_repository.dart';
import 'login_screen.dart';

/// Кореневий екран: слухає стан автентифікації Firebase і показує
/// вхід або головну частину застосунку. Після перезапуску сеанс
/// відновлюється автоматично – перша подія потоку вже містить користувача.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<User?> _subscription;
  bool _restoring = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _subscription = AuthRepository.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    final changed = !_restoring && user?.uid != _user?.uid;
    setState(() {
      _restoring = false;
      _user = user;
    });
    CrashReporting.setUser(user?.uid);
    // Вхід або вихід закриває екрани, відкриті поверх (реєстрація, відновлення пароля).
    if (changed) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) return const _SplashScreen();
    return _user == null ? const LoginScreen() : const MainShell();
  }
}

/// Поки Firebase відновлює збережений сеанс.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Відновлення сеансу…', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
