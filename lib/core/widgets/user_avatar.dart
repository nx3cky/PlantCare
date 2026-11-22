import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Круглий аватар: фото за посиланням [photoUrl] або ініціали;
/// за потреби – значок камери для зміни фото.
class UserAvatar extends StatelessWidget {
  final String initials;
  final String? photoUrl;
  final double size;
  final VoidCallback? onEditPhoto;

  const UserAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.size = 48,
    this.onEditPhoto,
  });

  /// Ініціали з імені («Микола Гейко» → «МГ») або з email.
  static String initialsOf(String? name, [String? email]) {
    final source = (name?.trim().isNotEmpty ?? false) ? name!.trim() : (email ?? '').trim();
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'[\s@.]+')).where((p) => p.isNotEmpty).toList();
    final letters = parts.take(2).map((p) => p.characters.first.toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: hasPhoto ? AppColors.primaryContainer : AppColors.primary,
      foregroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      // Якщо фото не завантажилось – лишаються ініціали.
      onForegroundImageError: hasPhoto ? (_, _) {} : null,
      child: Text(
        initials,
        style: TextStyle(
          color: hasPhoto ? AppColors.onPrimaryContainer : AppColors.onPrimary,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (onEditPhoto == null) return avatar;

    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.primaryContainer,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.surface, width: 3),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEditPhoto,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.photo_camera, size: 18, color: AppColors.onPrimaryContainer),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
