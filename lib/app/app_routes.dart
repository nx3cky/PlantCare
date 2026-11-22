import 'package:material_ui/material_ui.dart';

import '../core/data/models/plant.dart';
import '../features/auth/auth_gate.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/plants/plant_details_screen.dart';
import '../features/plants/plant_form_screen.dart';

/// Іменовані маршрути застосунку. Вибір між входом і головною частиною
/// робить [AuthGate] за станом AuthBloc; решта екранів відкривається поверх.
abstract final class AppRoutes {
  static const root = '/';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  /// Аргумент – id рослини.
  static const plantDetails = '/plant';

  /// Аргумент – рослина для редагування або null для нової.
  static const plantForm = '/plant/edit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      register => const RegisterScreen(),
      forgotPassword => ForgotPasswordScreen(initialEmail: settings.arguments as String?),
      plantDetails => PlantDetailsScreen(plantId: settings.arguments! as String),
      plantForm => PlantFormScreen(plant: settings.arguments as Plant?),
      _ => const AuthGate(),
    };
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
      // Форма відкривається знизу як повноекранний діалог (кнопка «×»).
      fullscreenDialog: settings.name == plantForm,
    );
  }
}
