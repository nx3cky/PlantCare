import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Єдиний спосіб показати користувачу результат дії: успіх або помилку,
/// за потреби – з кнопкою «Скасувати» ([actionLabel], [onAction]).
extension AppSnackBar on BuildContext {
  void showMessage(String text, {bool isError = false, String? actionLabel, VoidCallback? onAction}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : null,
          // З кнопкою дії SnackBar не зникає сам у Material 3 – задаємо явно.
          duration: const Duration(seconds: 4),
          persist: false,
          action: actionLabel == null
              ? null
              : SnackBarAction(label: actionLabel, textColor: AppColors.primaryContainer, onPressed: onAction ?? () {}),
          content: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
  }
}
