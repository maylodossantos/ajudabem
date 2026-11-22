import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../domain/entities/care_case.dart';

class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({required this.urgency, super.key});

  final Urgency urgency;

  @override
  Widget build(BuildContext context) {
    return AppBadge(label: urgency.badgeLabel, tone: urgency.tone, dot: true);
  }
}

class NeedChips extends StatelessWidget {
  const NeedChips({required this.needs, super.key, this.maxVisible});

  final List<String> needs;
  final int? maxVisible;

  static IconData iconOf(String need) {
    final name = need.toLowerCase();
    if (name.contains('aliment') || name.contains('comida')) {
      return Icons.restaurant_outlined;
    }
    if (name.contains('morad') || name.contains('abrigo')) {
      return Icons.home_outlined;
    }
    if (name.contains('saúde') ||
        name.contains('saude') ||
        name.contains('remédio') ||
        name.contains('remedio')) {
      return Icons.medical_services_outlined;
    }
    if (name.contains('roupa') || name.contains('agasalho')) {
      return Icons.checkroom_outlined;
    }
    if (name.contains('emocional') || name.contains('psico')) {
      return Icons.psychology_outlined;
    }
    if (name.contains('reabilit') || name.contains('depend')) {
      return Icons.healing_outlined;
    }
    if (name.contains('higiene') || name.contains('banho')) {
      return Icons.soap_outlined;
    }
    if (name.contains('document')) return Icons.badge_outlined;
    if (name.contains('trabalho') || name.contains('emprego')) {
      return Icons.work_outline;
    }
    return Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    if (needs.isEmpty) {
      return Text(
        'Nenhuma necessidade marcada.',
        style: GoogleFonts.manrope(
          color: AppColors.textSecondary,
          fontSize: AppTextSize.small,
        ),
      );
    }

    final limit = maxVisible;
    final visible = limit == null || needs.length <= limit
        ? needs
        : needs.take(limit - 1).toList();
    final hidden = needs.length - visible.length;

    return Wrap(
      spacing: AppSpacing.sm - 2,
      runSpacing: AppSpacing.sm - 2,
      children: [
        for (final need in visible) AppTag(label: need, icon: iconOf(need)),
        if (hidden > 0) AppTag(label: '+$hidden'),
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
      color: AppColors.textMuted,
      fontSize: AppTextSize.body,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.fullName,
                  style: GoogleFonts.manrope(
                    fontSize: AppTextSize.heading,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                if (person.cityLabel.isNotEmpty)
                  Text(person.cityLabel, style: muted),
                const SizedBox(height: 4),
                UrgencyBadge(urgency: person.urgency),
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
        : CareRecordStatus.inCare.background;
    final dot = finished
        ? CareRecordStatus.finished.dot
        : CareRecordStatus.inCare.dot;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: dot, size: 14),
          const SizedBox(width: 10),
          Text(
            finished ? 'Finalizado' : 'Em andamento',
            style: GoogleFonts.manrope(
              fontSize: AppTextSize.title,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class CareActionSelector extends StatelessWidget {
  const CareActionSelector({
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final CareRecordStatus value;
  final List<CareRecordStatus> options;
  final ValueChanged<CareRecordStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.manrope(
      color: AppColors.textStrong,
      fontSize: AppTextSize.title,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );

    Widget labelOf(CareRecordStatus status, {required bool selected}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 12, color: status.dot),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            selected ? status.label : status.action,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: value.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: options.isEmpty
          ? labelOf(value, selected: true)
          : DropdownButtonHideUnderline(
              child: DropdownButton<CareRecordStatus>(
                value: options.contains(value) ? value : null,
                isExpanded: true,
                borderRadius: BorderRadius.circular(AppRadius.md),
                icon: const Icon(Icons.keyboard_arrow_down),
                selectedItemBuilder: (_) => [
                  for (final option in options)
                    labelOf(option, selected: false),
                ],
                items: [
                  for (final option in options)
                    DropdownMenuItem(
                      value: option,
                      child: labelOf(option, selected: false),
                    ),
                ],
                onChanged: (option) {
                  if (option != null) onChanged(option);
                },
              ),
            ),
    );
  }
}
