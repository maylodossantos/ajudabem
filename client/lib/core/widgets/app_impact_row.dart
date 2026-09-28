import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppImpactRow extends StatelessWidget {
  const AppImpactRow({required this.items, super.key});

  final List<(int?, String)> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, (value, label)) in items.indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: _ImpactItem(value: value?.toString() ?? '–', label: label),
          ),
        ],
      ],
    );
  }
}

class _ImpactItem extends StatelessWidget {
  const _ImpactItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: const Color(0xFF232323),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
