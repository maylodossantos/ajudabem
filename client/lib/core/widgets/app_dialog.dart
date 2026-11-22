import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'app_svg_icon.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
    super.key,
    this.content,
  });

  final Widget icon;
  final String title;
  final String message;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceSubtle,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const AppSvgIcon(AppIcons.close, size: 20),
                  tooltip: 'Fechar',
                ),
              ),
              icon,
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.textStrong,
                  fontSize: AppTextSize.display,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.textStrong,
                  fontSize: AppTextSize.body,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              if (content != null) ...[const SizedBox(height: 18), content!],
              const SizedBox(height: 24),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDialogIcon extends StatelessWidget {
  const AppDialogIcon({
    required this.icon,
    super.key,
    this.color = AppColors.textStrong,
    this.background = AppColors.border,
    this.size = 64,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
