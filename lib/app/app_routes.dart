import 'package:flutter/material.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/shell/main_shell.dart';

/// Іменовані маршрути застосунку.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      register => const RegisterScreen(),
      forgotPassword => const ForgotPasswordScreen(),
      home => const MainShell(),
      profile => const MainShell(initialTab: MainShell.profileTab),
      _ => const LoginScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
