import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Логотип застосунку: листок на світло-зеленому квадраті.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.eco, color: AppColors.primary, size: size * 0.45),
    );
  }
}
