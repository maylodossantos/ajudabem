import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppInfoBanner extends StatelessWidget {
  const AppInfoBanner({
    required this.message,
    super.key,
    this.icon = Icons.info_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textBody, size: 28),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                color: AppColors.textBody,
                fontSize: AppTextSize.small,
                fontWeight: FontWeight.w700,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
