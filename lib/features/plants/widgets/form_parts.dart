import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/plant_image.dart';

/// Кнопки «− 14 днів +» для періодичності процедури.
/// [min] = 0 означає «не потрібно» (наприклад, підживлення сукулента).
class IntervalStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const IntervalStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.max = 90});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineStrong),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Менше',
            visualDensity: VisualDensity.compact,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 20),
          ),
          SizedBox(
            width: 76,
            child: Text(
              value == 0 ? 'не треба' : DateFormatUa.days(value),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Більше',
            visualDensity: VisualDensity.compact,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Рядок правила догляду: кольорова іконка, назва та елемент керування.
class CareRuleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final Widget trailing;

  const CareRuleRow({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          trailing,
        ],
      ),
    );
  }
}

/// Плитка «Камера» / «Галерея» у блоці фото.
class PhotoSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PhotoSourceTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineStrong),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 104,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Вибір фото з набору зображень, вбудованих у застосунок
/// (камера й галерея потребують image_picker і Firebase Storage).
abstract final class PlantPhotoPicker {
  static const images = [
    'assets/images/monstera.jpg',
    'assets/images/ficus.jpg',
    'assets/images/chloro.jpg',
    'assets/images/spathiphyllum.png',
    'assets/images/zamio.jpg',
    'assets/images/sansevieria.jpg',
    'assets/images/echeveria.jpg',
  ];

  /// Повертає шлях до обраного зображення або null.
  static Future<String?> show(BuildContext context, {String? selected}) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Фото з бібліотеки', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final img in images)
                    GestureDetector(
                      onTap: () => Navigator.pop(context, img),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: img == selected ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: PlantImage(img, borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
