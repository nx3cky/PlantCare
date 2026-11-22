import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Фото рослини: asset із застосунку, HTTPS-посилання або заглушка з листком.
class PlantImage extends StatelessWidget {
  final String? source;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const PlantImage(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(Icons.eco, color: AppColors.primary.withValues(alpha: 0.6), size: 32),
    );
    final src = source;
    final Widget image = src == null || src.isEmpty
        ? placeholder
        : src.startsWith('http')
            ? Image.network(src, width: width, height: height, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder)
            : Image.asset(src, width: width, height: height, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder);
    return ClipRRect(borderRadius: borderRadius, child: image);
  }
}
