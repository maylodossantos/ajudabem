import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_status_pill.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';

TextStyle _detail() => GoogleFonts.manrope(
  color: AppColors.textStrong,
  fontSize: AppTextSize.small,
  letterSpacing: 0,
);

class InitiativeCardShell extends StatelessWidget {
  const InitiativeCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({required this.campaign, required this.onOpen, super.key});

  final Campaign campaign;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      onTap: onOpen,
      leading: SizedBox(
        width: 84,
        child: AppCoverImage(
          imageUrl: campaign.coverImage,
          aspectRatio: 1,
          borderRadius: BorderRadius.circular(AppRadius.md),
          placeholder: const ColoredBox(
            color: AppColors.border,
            child: Icon(Icons.campaign_outlined, color: Colors.white),
          ),
        ),
      ),
      title: campaign.title,
      subtitle: campaign.organizationName,
      details: [
        AppDetail(
          Icons.schedule_outlined,
          campaign.deadlineLabel(DateTime.now()),
        ),
      ],
      footer: SizedBox(
        width: double.infinity,
        child: AppTonalButton(
          key: Key('campaign_open_${campaign.id}'),
          label: 'Ver detalhes',
          onPressed: onOpen,
        ),
      ),
    );
  }
}

class ScheduleLine extends StatelessWidget {
  const ScheduleLine({required this.action, super.key, this.prefix = ''});

  final VolunteerAction action;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text('$prefix${action.dateLabel}', style: _detail()),
        Icon(
          Icons.circle,
          size: 6,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(action.scheduleLabel, style: _detail()),
      ],
    );
  }
}

class ManagedActionCard extends StatelessWidget {
  const ManagedActionCard({
    required this.action,
    required this.onOpen,
    required this.onVolunteers,
    super.key,
  });

  final VolunteerAction action;
  final VoidCallback onOpen;
  final VoidCallback onVolunteers;

  @override
  Widget build(BuildContext context) {
    final pending = action.pendingCount;

    return AppListCard(
      onTap: onOpen,
      title: action.title,
      badge: action.isOverdue(DateTime.now())
          ? AppStatusPill(
              key: Key('action_overdue_${action.id}'),
              label: 'Data vencida',
              color: AppColors.warningText,
              background: AppColors.warningSoft,
            )
          : null,
      details: [
        AppDetail(
          Icons.groups_outlined,
          action.isActive
              ? '${action.volunteersLabel} · ${action.vacanciesLabel}'
              : 'Ação finalizada',
        ),
        AppDetail(
          Icons.event_outlined,
          '${action.dateLabel} · ${action.scheduleLabel}',
        ),
      ],
      footer: AppCardActions(
        secondaryLabel: 'Ver detalhes',
        onSecondary: onOpen,
        primaryLabel: pending > 0
            ? 'Ver voluntários ($pending)'
            : 'Ver voluntários',
        primaryKey: Key('action_volunteers_${action.id}'),
        onPrimary: onVolunteers,
      ),
    );
  }
}

class OpenActionCard extends StatelessWidget {
  const OpenActionCard({
    required this.action,
    required this.isApplying,
    required this.onOpen,
    required this.onApply,
    super.key,
  });

  final VolunteerAction action;
  final bool isApplying;
  final VoidCallback onOpen;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final application = action.myApplication;

    return AppListCard(
      onTap: onOpen,
      title: action.title,
      details: [
        AppDetail(Icons.place_outlined, action.placeLabel),
        AppDetail(
          Icons.event_outlined,
          '${action.dateLabel} · ${action.scheduleLabel}',
        ),
        AppDetail(Icons.apartment_outlined, action.organizationName),
      ],
      footer: AppCardActions(
        secondaryLabel: 'Ver detalhes',
        onSecondary: onOpen,
        primaryLabel: switch (application) {
          ApplicationStatus.accepted => 'Participando',
          ApplicationStatus.pending => 'Aguardando',
          null when action.isFull => 'Vagas esgotadas',
          null => 'Candidatar',
        },
        primaryKey: Key('action_apply_${action.id}'),
        primaryDone: application != null || action.isFull,
        isLoading: isApplying,
        onPrimary: onApply,
      ),
    );
  }
}
