import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Круглий аватар з ініціалами; за потреби – значок камери для зміни фото.
class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final VoidCallback? onEditPhoto;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.onPrimary,
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
