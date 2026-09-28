import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_avatar.dart';
import '../../domain/entities/care_case.dart';

class UrgencyBar extends StatelessWidget {
  const UrgencyBar({required this.urgency, super.key, this.width = 104});

  final Urgency urgency;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Urgência ${urgency.label.toLowerCase()}',
      child: Container(
        width: width,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [urgency.color.withValues(alpha: 0.25), urgency.color],
          ),
        ),
        child: Text(
          urgency.label,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class NeedChips extends StatelessWidget {
  const NeedChips({required this.needs, super.key});

  final List<String> needs;

  static const _palette = [
    Color(0xFFFFD6A5),
    Color(0xFFA0C4FF),
    Color(0xFFCAFFBF),
    Color(0xFFFFADAD),
    Color(0xFFBDB2FF),
    Color(0xFF9BF6FF),
  ];

  static Color colorOf(String need) =>
      _palette[need.codeUnits.fold(0, (sum, unit) => sum + unit) %
          _palette.length];

  @override
  Widget build(BuildContext context) {
    if (needs.isEmpty) {
      return Text(
        'Nenhuma necessidade marcada.',
        style: GoogleFonts.manrope(fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final need in needs)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorOf(need),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              need,
              style: GoogleFonts.manrope(
                color: const Color(0xFF454545),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
      ],
    );
  }
}

class CareCaseHeader extends StatelessWidget {
  const CareCaseHeader({required this.person, super.key});

  final CareCase person;

  @override
  Widget build(BuildContext context) {
    final muted = GoogleFonts.manrope(
      color: const Color(0xFFA2A2A2),
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const AppAvatar(radius: 42, imageUrl: null),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.fullName,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                if (person.cityLabel.isNotEmpty)
                  Text(person.cityLabel, style: muted),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Urgência: ', style: muted),
                    UrgencyBar(urgency: person.urgency, width: 90),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CareStatusBanner extends StatelessWidget {
  const CareStatusBanner({required this.status, super.key});

  final CareStatus status;

  @override
  Widget build(BuildContext context) {
    final finished = status == CareStatus.finished;
    final background = finished
        ? CareRecordStatus.finished.background
        : CareRecordStatus.inProgress.background;
    final dot = finished
        ? CareRecordStatus.finished.dot
        : CareRecordStatus.inProgress.dot;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: dot, size: 14),
          const SizedBox(width: 10),
          Text(
            finished ? 'Finalizado' : 'Em andamento',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
