import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  /// Defaults to the theme's primary (brand) color.
  final Color? color;

  /// Replaces the content with just a spinner and blocks taps, keeping the
  /// brand color instead of the gray disabled look.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final primary = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 39,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isLoading ? primary : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
      style: GoogleFonts.manrope(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    final icon = this.icon;
    if (icon == null) {
      return text;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [icon, const SizedBox(width: 8), text],
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final child = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.manrope(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: icon == null
            ? child
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 6),
                  Flexible(child: child),
                ],
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
          fontSize: 14,
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
