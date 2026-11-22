import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.color,
    this.height = 39,
    this.radius = AppRadius.sm,
    this.horizontalPadding = 16,
    this.fontSize = AppTextSize.title,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  final Color? color;

  final bool isLoading;
  final double height;
  final double radius;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final primary = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isLoading ? primary : null,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: isLoading ? _spinner : _content(),
      ),
    );
  }

  static const _spinner = SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  Widget _content() {
    final text = Text(
      label,
      maxLines: 1,
      softWrap: false,
      style: GoogleFonts.manrope(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    final icon = this.icon;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [icon, const SizedBox(width: 8), text],
            ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.color,
    this.dense = false,
    this.height = 39,
    this.radius = AppRadius.sm,
    this.fontSize,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? color;
  final bool dense;
  final double height;
  final double radius;
  final double? fontSize;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;
    final child = Text(
      label,
      maxLines: 1,
      softWrap: false,
      style: GoogleFonts.manrope(
        color: color,
        fontSize: fontSize ?? (dense ? AppTextSize.body : AppTextSize.title),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor ?? color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 16),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: icon == null
              ? child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 6), child],
                ),
        ),
      ),
    );
  }
}

class AppTonalButton extends StatelessWidget {
  const AppTonalButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.surfaceMuted,
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: const Size(150, 46),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Theme.of(context).colorScheme.primary,
          fontSize: AppTextSize.title,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: AppTextSize.body,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class AppDangerTextButton extends StatelessWidget {
  const AppDangerTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.danger,
        minimumSize: const Size.fromHeight(44),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: AppColors.danger,
          fontSize: AppTextSize.title,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

abstract final class AppButtonLabel {
  static TextStyle style(Color color, double fontSize) => GoogleFonts.manrope(
    color: color,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static double fitSize(
    List<String> labels,
    double width, {
    double max = AppTextSize.title,
    double min = AppTextSize.caption,
  }) {
    for (var size = max; size > min; size -= 0.5) {
      final fits = labels.every((label) {
        final painter = TextPainter(
          text: TextSpan(text: label, style: style(Colors.black, size)),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        return painter.width <= width;
      });
      if (fits) return size;
    }
    return min;
  }
}
