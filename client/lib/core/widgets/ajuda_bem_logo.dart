import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AjudaBemLogo extends StatelessWidget {
  const AjudaBemLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.manrope(
          color: const Color(0xFF232323),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        children: [
          const TextSpan(text: 'Ajuda'),
          TextSpan(
            text: 'Bem',
            style: GoogleFonts.manrope(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
