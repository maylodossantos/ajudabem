import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppDetail {
  const AppDetail(this.icon, this.text, {this.color});

  final IconData icon;
  final String text;
  final Color? color;
}

class AppListCard extends StatelessWidget {
  const AppListCard({
    required this.title,
    super.key,
    this.leading,
    this.subtitle,
    this.badge,
    this.trailing,
    this.details = const [],
    this.body,
    this.footer,
    this.onTap,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final Widget? trailing;
  final List<AppDetail> details;
  final Widget? body;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);
    final subtitle = this.subtitle;
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        hoverColor: primary.withValues(alpha: 0.04),
        splashColor: primary.withValues(alpha: 0.08),
        highlightColor: primary.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading case final leading?) ...[
                    leading,
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  color: AppColors.textStrong,
                                  fontSize: AppTextSize.title,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            if (badge case final badge?) ...[
                              const SizedBox(width: AppSpacing.sm),
                              badge,
                            ],
                            ?trailing,
                          ],
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: AppColors.textSecondary,
                              fontSize: AppTextSize.small,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                        for (final detail in details) ...[
                          const SizedBox(height: AppSpacing.xs + 2),
                          _DetailLine(detail: detail),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (body case final body?) ...[
                const SizedBox(height: AppSpacing.md),
                body,
              ],
              if (footer case final footer?) ...[
                const SizedBox(height: AppSpacing.md),
                footer,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.detail});

  final AppDetail detail;

  @override
  Widget build(BuildContext context) {
    final color = detail.color ?? AppColors.textBody;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            detail.icon,
            size: 16,
            color: detail.color ?? AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            detail.text,
            style: GoogleFonts.manrope(
              color: color,
              fontSize: AppTextSize.small,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
