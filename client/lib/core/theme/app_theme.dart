import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './app_colors.dart';

abstract final class AppTheme {
  static const _brand = AppColors.brand;
  static const _accent = AppColors.accent;
  static const _surface = AppColors.background;
  static const _text = AppColors.textStrong;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brand,
      primary: _brand,
      secondary: _accent,
      surface: _surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: _text,
        displayColor: _text,
      ),
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _surface,
        foregroundColor: _text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(39),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        hintStyle: GoogleFonts.manrope(
          color: AppColors.textMuted,
          fontSize: AppTextSize.title,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
