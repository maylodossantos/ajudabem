import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    required this.icon,
    super.key,
    this.iconColor = AppColors.textMuted,
    this.backgroundColor = AppColors.surfaceMuted,
    this.size = 108,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.42, color: iconColor),
    );
  }
}
