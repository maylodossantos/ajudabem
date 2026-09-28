import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_button.dart';

class AppStatusView extends StatelessWidget {
  const AppStatusView({
    required this.illustration,
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
    this.footer,
  });

  final Widget illustration;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 220, child: illustration),
              const SizedBox(height: 36),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF232323),
                  fontSize: 15,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              if (footer != null) ...[const SizedBox(height: 16), footer!],
              if (actionLabel != null) ...[
                const SizedBox(height: 20),
                AppTonalButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
