import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';

/// Картка запланованої процедури догляду з кнопкою «виконано».
class CareTaskCard extends StatelessWidget {
  final CareTask task;
  final bool done;
  final VoidCallback onToggle;

  const CareTaskCard({
    super.key,
    required this.task,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = task.overdue && !done;
    final accent = overdue ? AppColors.error : AppColors.primary;
    final subtitleColor = overdue ? AppColors.error : AppColors.muted;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: overdue ? AppColors.errorSurface : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: overdue ? const Color(0xFFF5B5AE) : AppColors.outline),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(task.image, width: 48, height: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${task.action} · ${task.plant}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      overdue ? Icons.warning_rounded : task.icon,
                      size: 15,
                      color: overdue
                          ? AppColors.error
                          : task.kind == CareKind.water
                              ? AppColors.water
                              : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        done ? 'Виконано сьогодні' : task.subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: subtitleColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: done ? 'Скасувати' : 'Позначити виконаним',
            onPressed: onToggle,
            style: IconButton.styleFrom(
              backgroundColor: done ? accent : Colors.transparent,
              side: BorderSide(color: accent, width: 2),
              fixedSize: const Size(44, 44),
            ),
            icon: Icon(Icons.check, color: done ? Colors.white : accent),
          ),
        ],
      ),
    );
  }
}
