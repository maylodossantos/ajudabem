import 'package:flutter/material.dart';

class AppCoverImage extends StatelessWidget {
  const AppCoverImage({
    required this.imageUrl,
    super.key,
    this.borderRadius,
    this.placeholder,
    this.aspectRatio = 16 / 9,
  });

  final String? imageUrl;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final fallback = placeholder == null
        ? const SizedBox.shrink()
        : ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: AspectRatio(aspectRatio: aspectRatio, child: placeholder),
          );
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
