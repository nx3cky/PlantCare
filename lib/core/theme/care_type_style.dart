import 'package:material_ui/material_ui.dart';

import '../data/models/care_entry.dart';
import 'app_colors.dart';

/// Іконка й кольори кожного типу процедури (як у макетах ЛР2).
extension CareTypeStyle on CareType {
  IconData get icon => switch (this) {
        CareType.watering => Icons.water_drop,
        CareType.fertilizing => Icons.science,
        CareType.pruning => Icons.content_cut,
        CareType.repotting => Icons.swap_vert,
        CareType.spraying => Icons.sanitizer,
        CareType.other => Icons.more_horiz,
      };

  Color get color => switch (this) {
        CareType.watering => AppColors.water,
        CareType.fertilizing => AppColors.primary,
        CareType.pruning => const Color(0xFF6A4FB3),
        CareType.repotting => const Color(0xFF7A4E1D),
        CareType.spraying => const Color(0xFF00796B),
        CareType.other => AppColors.muted,
      };

  Color get background => switch (this) {
        CareType.watering => AppColors.waterContainer,
        CareType.fertilizing => const Color(0xFFD4EDD0),
        CareType.pruning => const Color(0xFFEDE4FA),
        CareType.repotting => const Color(0xFFF3E6DA),
        CareType.spraying => const Color(0xFFDDF0EC),
        CareType.other => AppColors.surfaceVariant,
      };
}

/// Кругла іконка типу процедури.
class CareTypeIcon extends StatelessWidget {
  final CareType type;
  final double size;

  const CareTypeIcon(this.type, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: type.background, shape: BoxShape.circle),
      child: Icon(type.icon, color: type.color, size: size * 0.5),
    );
  }
}
