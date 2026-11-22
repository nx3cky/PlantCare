import 'package:material_ui/material_ui.dart';

import '../data/models/care_schedule.dart';
import '../theme/app_colors.dart';
import '../theme/care_type_style.dart';
import 'plant_image.dart';

/// Картка процедури на сьогодні з кнопкою «виконано».
class CareTaskCard extends StatelessWidget {
  final CareTask task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const CareTaskCard({super.key, required this.task, required this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final done = task.done;
    final overdue = task.overdue;
    final accent = overdue ? AppColors.error : AppColors.primary;

    return Material(
      color: overdue ? AppColors.errorSurface : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: overdue ? const Color(0xFFF5B5AE) : AppColors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PlantImage(task.plant.image, width: 48, height: 48, borderRadius: BorderRadius.circular(10)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task.action} · ${task.plant.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          overdue ? Icons.warning_rounded : task.type.icon,
                          size: 15,
                          color: overdue ? AppColors.error : task.type.color,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            task.subtitle,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: overdue ? AppColors.error : AppColors.muted),
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
        ),
      ),
    );
  }
}
