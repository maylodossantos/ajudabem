import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCardActions extends StatelessWidget {
  const AppCardActions({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    super.key,
    this.primaryKey,
    this.primaryDone = false,
    this.isLoading = false,
    this.secondaryLeading,
  });

  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final Key? primaryKey;
  final bool primaryDone;
  final bool isLoading;
  final Widget? secondaryLeading;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final done = primary.withValues(alpha: 0.5);
    TextStyle style(Color color) => GoogleFonts.manrope(
      color: color,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: onSecondary,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEBEBEB),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: shape,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (secondaryLeading case final leading?) ...[
                    leading,
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      secondaryLabel,
                      overflow: TextOverflow.ellipsis,
                      style: style(primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton(
              key: primaryKey,
              onPressed: primaryDone || isLoading ? null : onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: primaryDone ? done : primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: shape,
              ),
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      primaryLabel,
                      overflow: TextOverflow.ellipsis,
                      style: style(Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
