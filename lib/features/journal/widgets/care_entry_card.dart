import 'package:material_ui/material_ui.dart';

import '../../../core/data/models/care_entry.dart';
import '../../../core/data/models/plant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/care_type_style.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/plant_image.dart';

/// Картка запису журналу: тип, рослина, нотатка, час і мініатюра фото.
class CareEntryCard extends StatelessWidget {
  final CareEntry entry;
  final Plant? plant;
  final VoidCallback onTap;

  const CareEntryCard({super.key, required this.entry, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CareTypeIcon(entry.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.type.label} · ${plant?.name ?? 'Рослину видалено'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (entry.notes.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(entry.notes, style: const TextStyle(fontSize: 14, height: 1.3, color: AppColors.muted)),
                    ],
                    if (entry.photo != null) ...[
                      const SizedBox(height: 4),
                      Text(DateFormatUa.time(entry.performedAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              entry.photo != null
                  ? PlantImage(entry.photo, width: 64, height: 64, borderRadius: BorderRadius.circular(12))
                  : Text(DateFormatUa.time(entry.performedAt),
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
