import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Кнопка-«пігулка» на всю ширину: заповнена (основна дія)
/// або контурна (другорядна дія). Під час запиту ([isLoading]) показує
/// індикатор і не реагує на натискання – повторне надсилання заблоковане.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
    const textStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
    final Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: outlined ? AppColors.primary : AppColors.onPrimary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Flexible(child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis)),
            ],
          );
    final action = isLoading ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: action,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.outlineStrong),
                shape: shape,
              ),
              child: child,
            )
          : FilledButton(
              onPressed: action,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                // Під час завантаження кнопка лишається зеленою, а не сірою.
                disabledBackgroundColor:
                    isLoading ? AppColors.primary.withValues(alpha: 0.85) : null,
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}
