import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppFloatingPill extends StatelessWidget {
  const AppFloatingPill({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textStrong,
      elevation: 4,
      shadowColor: Colors.black38,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 140, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: AppTextSize.body,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({
    required this.activeLabels,
    required this.onOpen,
    super.key,
    this.elevated = true,
  });

  final List<String> activeLabels;
  final VoidCallback onOpen;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final active = activeLabels.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        spacing: 8,
        children: [
          _FilterChip(
            key: const Key('app_filter_bar_open'),
            label: active ? 'Filtros · ${activeLabels.length}' : 'Filtros',
            icon: Icons.tune,
            background: active ? primary : Colors.white,
            foreground: active ? Colors.white : AppColors.textStrong,
            elevated: elevated,
            onTap: onOpen,
          ),
          for (final label in activeLabels)
            _FilterChip(
              label: label,
              background: Colors.white,
              foreground: primary,
              elevated: elevated,
              onTap: onOpen,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.elevated,
    super.key,
    this.icon,
  });

  final String label;
  final bool elevated;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      elevation: elevated ? 3 : 0,
      shadowColor: Colors.black26,
      shape: StadiumBorder(
        side: elevated
            ? BorderSide.none
            : const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon case final icon?) ...[
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: foreground,
                  fontSize: AppTextSize.small,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
