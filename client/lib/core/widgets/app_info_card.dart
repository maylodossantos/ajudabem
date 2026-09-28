import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({required this.child, super.key, this.title});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title case final title?) ...[
            Text(
              title,
              style: GoogleFonts.manrope(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }
}

class AppBulletList extends StatelessWidget {
  const AppBulletList({required this.lines, super.key});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.manrope(
      color: const Color(0xFF232323),
      fontSize: 14,
      height: 1.35,
      letterSpacing: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 2),
            child: Text('•  $line', style: style),
          ),
      ],
    );
  }

  static List<String> linesOf(String? text) => (text ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

class AppFieldGrid extends StatelessWidget {
  const AppFieldGrid({required this.fields, super.key, this.muted = false});

  final List<(String, String)> fields;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.manrope(
      color: muted ? const Color(0xFFA2A2A2) : Colors.black,
      fontSize: muted ? 13 : 15,
      fontWeight: muted ? FontWeight.w400 : FontWeight.w700,
      letterSpacing: 0,
    );
    final valueStyle = GoogleFonts.manrope(
      color: const Color(0xFF454545),
      fontSize: 13,
      letterSpacing: 0,
    );

    Widget cell((String, String) field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.$1, style: labelStyle),
        const SizedBox(height: 2),
        Text(field.$2.isEmpty ? '—' : field.$2, style: valueStyle),
      ],
    );

    return Column(
      children: [
        for (var i = 0; i < fields.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cell(fields[i])),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < fields.length
                      ? cell(fields[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
