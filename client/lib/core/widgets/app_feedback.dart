import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Theme.of(dialogContext).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF232323),
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 26),
              AppPrimaryButton(
                key: const Key('confirm_dialog_cancel'),
                label: 'Cancelar',
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              const SizedBox(height: 4),
              TextButton(
                key: const Key('confirm_dialog_confirm'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: Text(
                  confirmLabel,
                  style: GoogleFonts.manrope(
                    color: AppColors.danger,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return confirmed ?? false;
}
