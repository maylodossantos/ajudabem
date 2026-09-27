import 'package:flutter/material.dart';

/// 16:9 cover photo; renders nothing when there's no URL or it fails to load.
class AppCoverImage extends StatelessWidget {
  const AppCoverImage({required this.imageUrl, super.key, this.borderRadius});

  final String? imageUrl;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
