import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme exposes AjudaBem colors and Manrope text theme', () {
    final theme = AppTheme.light;

    expect(theme.scaffoldBackgroundColor, const Color(0xFFF3F3F3));
    expect(theme.colorScheme.primary, const Color(0xFF04957C));
    expect(theme.textTheme.bodyMedium?.fontFamily, contains('Manrope'));
    expect(theme.inputDecorationTheme.fillColor, const Color(0xFFEEEEEE));
    expect(
      theme.inputDecorationTheme.hintStyle?.color,
      const Color(0xFFA2A2A2),
    );
    expect(theme.inputDecorationTheme.hintStyle?.fontSize, 16);
    expect(theme.inputDecorationTheme.hintStyle?.fontWeight, FontWeight.w400);
  });
}
