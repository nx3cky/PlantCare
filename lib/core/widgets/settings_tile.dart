import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Біла картка-контейнер для пунктів налаштувань профілю.
class SettingsCard extends StatelessWidget {
  final Widget child;
  final bool highlighted;

  const SettingsCard({super.key, required this.child, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted ? AppColors.primary : AppColors.outline,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Пункт налаштувань: іконка, заголовок, підзаголовок і елемент праворуч.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 16, color: AppColors.text)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
