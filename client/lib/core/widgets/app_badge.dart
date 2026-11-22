import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppTone {
  neutral(AppColors.textBody, AppColors.surfaceMuted),
  brand(AppColors.brandDark, AppColors.brandSoft),
  info(AppColors.infoText, AppColors.infoSoft),
  success(AppColors.successText, AppColors.successSoft),
  warning(AppColors.warningText, AppColors.warningSoft),
  danger(AppColors.dangerText, AppColors.dangerTint);

  const AppTone(this.strong, this.soft);

  final Color strong;
  final Color soft;
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    required this.tone,
    super.key,
    this.dot = false,
    this.icon,
  });

  final String label;
  final AppTone tone;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Icon(Icons.circle, size: 8, color: tone.strong),
            const SizedBox(width: 6),
          ] else if (icon case final icon?) ...[
            Icon(icon, size: 14, color: tone.strong),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: tone.strong,
                fontSize: AppTextSize.caption,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag({required this.label, super.key, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final icon?) ...[
            Icon(icon, size: 15, color: AppColors.brand),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.textBody,
              fontSize: AppTextSize.small,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
