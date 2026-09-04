import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const _brand = Color(0xFF04957C);
  static const _accent = Color(0xFFF2B84B);
  static const _surface = Color(0xFFF3F3F3);
  static const _text = Color(0xFF232323);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        hintStyle: GoogleFonts.manrope(
          color: const Color(0xFFA2A2A2),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        prefixIconColor: const Color(0xFFB5B5B5),
        suffixIconColor: const Color(0xFFB5B5B5),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
