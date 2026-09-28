import 'package:flutter/material.dart';

class AppSquareIconButton extends StatelessWidget {
  const AppSquareIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.color,
    this.background = Colors.white,
    this.size = 46,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      style: IconButton.styleFrom(
        backgroundColor: background,
        fixedSize: Size(size, size),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
