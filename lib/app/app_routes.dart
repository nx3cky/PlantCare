import 'package:flutter/material.dart';

import '../features/auth/auth_gate.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/register_screen.dart';

/// Іменовані маршрути застосунку. Вибір між входом і головною частиною
/// робить [AuthGate] за станом Firebase Auth, тому окремих маршрутів
/// для них немає: реєстрація й відновлення пароля відкриваються поверх входу.
abstract final class AppRoutes {
  static const root = '/';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      register => const RegisterScreen(),
      forgotPassword => ForgotPasswordScreen(initialEmail: settings.arguments as String?),
      _ => const AuthGate(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
