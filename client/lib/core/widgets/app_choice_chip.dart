import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: selected ? primary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? primary : const Color(0xFF232323)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: selected ? Colors.white : const Color(0xFF232323),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class AppChoiceChipGroup<T> extends StatelessWidget {
  const AppChoiceChipGroup({
    required this.options,
    required this.isSelected,
    required this.onToggle,
    required this.labelOf,
    super.key,
  });

  final List<T> options;
  final bool Function(T option) isSelected;
  final ValueChanged<T> onToggle;
  final String Function(T option) labelOf;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          AppChoiceChip(
            label: labelOf(option),
            selected: isSelected(option),
            onTap: () => onToggle(option),
          ),
      ],
    );
  }
}
