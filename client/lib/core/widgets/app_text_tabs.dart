import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTabs<T> extends StatelessWidget {
  const AppTextTabs({
    required this.tabs,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<(T, String)> tabs;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 28,
      children: [
        for (final (value, label) in tabs)
          InkWell(
            key: Key('tab_$label'),
            onTap: () => onSelected(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  color: value == selected
                      ? const Color(0xFF232323)
                      : const Color(0xFFA2A2A2),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
