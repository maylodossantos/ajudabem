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

  final Color? color;

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
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;
    final child = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.manrope(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: 39,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
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
        backgroundColor: const Color(0xFFE9E9E9),
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: const Size(150, 46),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
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
