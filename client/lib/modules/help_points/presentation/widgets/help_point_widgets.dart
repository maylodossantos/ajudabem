import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/geo/geo_point.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/app_status_pill.dart';
import '../../domain/entities/help_point.dart';

class HelpPointCover extends StatelessWidget {
  const HelpPointCover({
    required this.point,
    super.key,
    this.aspectRatio = 16 / 9,
    this.radius = 16,
  });

  final HelpPoint point;
  final double aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppCoverImage(
      imageUrl: point.coverImage,
      aspectRatio: aspectRatio,
      borderRadius: BorderRadius.circular(radius),
      placeholder: ColoredBox(
        color: const Color(0xFF343741),
        child: Center(
          child: Icon(
            _iconOf(point),
            color: Colors.white.withValues(alpha: 0.55),
            size: 34,
          ),
        ),
      ),
    );
  }

  static IconData _iconOf(HelpPoint point) {
    final services = point.services;
    if (services.contains(AssistanceType.shelter) ||
        services.contains(AssistanceType.overnight)) {
      return Icons.night_shelter_outlined;
    }
    if (services.contains(AssistanceType.food)) {
      return Icons.restaurant_outlined;
    }
    if (services.contains(AssistanceType.psychological)) {
      return Icons.psychology_outlined;
    }
    if (services.contains(AssistanceType.medical)) {
      return Icons.local_hospital_outlined;
    }
    if (services.contains(AssistanceType.clothing)) {
      return Icons.checkroom_outlined;
    }
    return Icons.volunteer_activism_outlined;
  }
}

class HelpPointCard extends StatelessWidget {
  const HelpPointCard({
    required this.point,
    required this.onTap,
    super.key,
    this.distanceKm,
    this.horizontal = false,
  });

  final HelpPoint point;
  final VoidCallback onTap;
  final double? distanceKm;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                point.cityLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF454545),
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (distanceKm case final km?)
              Text(
                GeoPoint.formatKm(km),
                style: GoogleFonts.manrope(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          point.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.25,
            letterSpacing: 0,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: horizontal
              ? Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: HelpPointCover(point: point, aspectRatio: 1.35),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: details),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HelpPointCover(point: point, aspectRatio: 1.8),
                    const SizedBox(height: 8),
                    details,
                  ],
                ),
        ),
      ),
    );
  }
}

class AssistanceTags extends StatelessWidget {
  const AssistanceTags({required this.services, super.key});

  final List<AssistanceType> services;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final type in services)
          AppStatusPill(
            label: type.label,
            color: Colors.white,
            background: type.color,
          ),
      ],
    );
  }
}
