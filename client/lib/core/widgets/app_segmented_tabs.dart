import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSegmentedTabs<T> extends StatelessWidget {
  const AppSegmentedTabs({
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (value, label) in tabs)
            Expanded(
              child: GestureDetector(
                key: Key('tab_$label'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: value == selected
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      color: value == selected
                          ? const Color(0xFF232323)
                          : const Color(0xFF7A7A7A),
                      fontSize: 14,
                      fontWeight: value == selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
