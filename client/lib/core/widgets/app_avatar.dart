import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.radius,
    super.key,
    this.imageUrl,
    this.placeholderIcon = Icons.person_outline,
  });

  final String? imageUrl;
  final double radius;
  final IconData? placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasPhoto = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.border,
      backgroundImage: hasPhoto ? NetworkImage(url) : null,
      child: hasPhoto || placeholderIcon == null
          ? null
          : Icon(placeholderIcon, size: radius, color: Colors.white),
    );
  }
}
