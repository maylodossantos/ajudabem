import 'package:flutter/material.dart';

abstract final class AppColors {
  static const brand = Color(0xFF04957C);
  static const brandDark = Color(0xFF037D68);
  static const brandSoft = Color(0xFFE1F5EE);
  static const accent = Color(0xFFF2B84B);

  static const textStrong = Color(0xFF232323);
  static const textBody = Color(0xFF454545);
  static const textSecondary = Color(0xFF7A7A7A);
  static const textMuted = Color(0xFFA2A2A2);

  static const background = Color(0xFFF3F3F3);
  static const surface = Colors.white;
  static const surfaceSubtle = Color(0xFFFAFAFA);
  static const surfaceMuted = Color(0xFFE8E8E8);
  static const border = Color(0xFFD9D9D9);
  static const coverDark = Color(0xFF343741);

  static const danger = Color(0xFFE53935);
  static const dangerSoft = Color(0x1AE53935);
  static const dangerText = Color(0xFFC62828);
  static const dangerTint = Color(0xFFFDECEC);

  static const infoText = Color(0xFF2F6FDE);
  static const infoSoft = Color(0xFFE6EEFC);

  static const success = Color(0xFF34C759);
  static const successText = Color(0xFF1E9E47);
  static const successSoft = Color(0xFFDDF6E4);

  static const warning = Color(0xFFF08A24);
  static const warningText = Color(0xFFE07B00);
  static const warningSoft = Color(0xFFFFF0D6);

  static const urgencyHigh = Color(0xFFE5484D);
  static const urgencyMedium = warning;
  static const urgencyLow = success;
  static const urgencyPending = Color(0xFFBDBDBD);
}

abstract final class AppTextSize {
  static const caption = 12.0;
  static const small = 13.0;
  static const body = 14.0;
  static const title = 16.0;
  static const heading = 18.0;
  static const display = 20.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

abstract final class AppRadius {
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const pill = 20.0;
}
