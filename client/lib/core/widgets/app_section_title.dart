import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        color: AppColors.textStrong,
        fontSize: AppTextSize.title,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}
