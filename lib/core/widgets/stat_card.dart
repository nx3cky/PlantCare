import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Картка-лічильник на головному екрані (рослини, задачі, прострочені).
class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final bool alert;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.alert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = alert ? AppColors.error : AppColors.text;
    return Material(
      color: alert ? AppColors.errorContainer : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: alert ? const Color(0xFFF5B5AE) : AppColors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: alert ? AppColors.error : AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: fg),
                  ),
                  const Spacer(),
                  Icon(icon, color: iconColor, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
