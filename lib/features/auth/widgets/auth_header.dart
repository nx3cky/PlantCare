import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';

enum AuthMode { login, register }

/// Спільна шапка екранів входу та реєстрації: логотип, назва, перемикач режимів.
class AuthHeader extends StatelessWidget {
  final AuthMode mode;

  const AuthHeader({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(),
        const SizedBox(height: 16),
        const Text(
          'Plant Care',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ваш помічник у догляді за рослинами',
          style: TextStyle(fontSize: 15, color: AppColors.muted),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AuthMode>(
            segments: const [
              ButtonSegment(value: AuthMode.login, label: Text('Вхід')),
              ButtonSegment(value: AuthMode.register, label: Text('Реєстрація')),
            ],
            selected: {mode},
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.secondaryContainer,
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              minimumSize: const Size.fromHeight(44),
            ),
            onSelectionChanged: (selection) {
              if (selection.first == mode) return;
              // Реєстрація відкривається поверх входу, тож назад – просто pop.
              if (selection.first == AuthMode.register) {
                Navigator.of(context).pushNamed(AppRoutes.register);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ],
    );
  }
}
