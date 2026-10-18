import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Заглушка для розділів, які будуть реалізовані в наступних лабораторних.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Розділ буде реалізовано в наступних лабораторних роботах',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
