import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Єдиний спосіб показати користувачу результат дії: успіх або помилку.
extension AppSnackBar on BuildContext {
  void showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : null,
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
  }
}
