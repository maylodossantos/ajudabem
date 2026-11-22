import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 3,
                    color: value == selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  color: value == selected
                      ? AppColors.textStrong
                      : AppColors.textMuted,
                  fontSize: AppTextSize.display,
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
