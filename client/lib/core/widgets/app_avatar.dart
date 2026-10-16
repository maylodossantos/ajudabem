import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFD9D9D9),
      backgroundImage: hasPhoto ? NetworkImage(url) : null,
      child: hasPhoto || placeholderIcon == null
          ? null
          : Icon(placeholderIcon, size: radius, color: Colors.white),
    );
  }
}
