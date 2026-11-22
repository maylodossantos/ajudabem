import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'app_svg_icon.dart';

class AppUtilityTile extends StatelessWidget {
  const AppUtilityTile({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  static const _maxHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);

    return Semantics(
      button: true,
      label: label.replaceAll('\n', ' '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                width: double.infinity,
                height: (constraints.maxWidth / 1.35).clamp(0, _maxHeight),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: radius,
                  ),
                  child: FractionallySizedBox(
                    heightFactor: 0.48,
                    child: AppSvgIcon(iconAsset, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.black,
                fontSize: AppTextSize.caption,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
