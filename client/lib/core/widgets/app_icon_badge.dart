import 'package:flutter/material.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    required this.icon,
    super.key,
    this.iconColor = const Color(0xFFA2A2A2),
    this.backgroundColor = const Color(0xFFE9E9E9),
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
