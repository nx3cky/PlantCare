import 'package:material_ui/material_ui.dart';

import '../../../core/data/models/care_schedule.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/plant_image.dart';

/// Мітка терміну поливу: синя, а якщо полив прострочено – червона.
class WateringBadge extends StatelessWidget {
  final CareSchedule schedule;

  const WateringBadge(this.schedule, {super.key});

  @override
  Widget build(BuildContext context) {
    final days = schedule.daysToWatering;
    final overdue = days < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: overdue ? AppColors.errorContainer : AppColors.waterContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(overdue ? Icons.warning_rounded : Icons.water_drop,
              size: 13, color: overdue ? AppColors.error : AppColors.water),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              days == 0 ? 'Полив сьогодні' : DateFormatUa.relative(days),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: overdue ? AppColors.error : AppColors.water,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Плитка рослини для сітки каталогу (GridView / SliverGrid).
class PlantGridTile extends StatelessWidget {
  final CareSchedule schedule;
  final VoidCallback onTap;

  const PlantGridTile({super.key, required this.schedule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final plant = schedule.plant;
    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: PlantImage(plant.image, width: double.infinity)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    plant.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  WateringBadge(schedule),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Рядок рослини для списку каталогу (ListView / SliverList).
class PlantListTile extends StatelessWidget {
  final CareSchedule schedule;
  final VoidCallback onTap;

  const PlantListTile({super.key, required this.schedule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final plant = schedule.plant;
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              PlantImage(plant.image, width: 64, height: 64, borderRadius: BorderRadius.circular(12)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                      plant.species.isEmpty ? plant.location : '${plant.species} · ${plant.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    WateringBadge(schedule),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
