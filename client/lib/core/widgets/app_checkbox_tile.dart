import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCheckboxTile extends StatelessWidget {
  const AppCheckboxTile({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  final InlineSpan label;

  static final textStyle = GoogleFonts.manrope(
    color: const Color(0xFF232323),
    fontSize: 13,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: value
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(3),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text.rich(label, style: textStyle)),
          ],
        ),
      ),
    );
  }
}
