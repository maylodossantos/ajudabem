import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';

TextStyle _title() => GoogleFonts.manrope(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.w700,
  letterSpacing: 0,
);

TextStyle _detail() => GoogleFonts.manrope(
  color: const Color(0xFF232323),
  fontSize: 13.5,
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
        borderRadius: BorderRadius.circular(12),
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
    return InitiativeCardShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: AppCoverImage(
              imageUrl: campaign.coverImage,
              aspectRatio: 1.15,
              borderRadius: BorderRadius.circular(10),
              placeholder: const ColoredBox(
                color: Color(0xFFD9D9D9),
                child: Icon(Icons.campaign_outlined, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _title(),
                ),
                Text(
                  campaign.organizationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF454545),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(campaign.deadlineLabel(DateTime.now()), style: _detail()),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: FilledButton(
                    key: Key('campaign_open_${campaign.id}'),
                    onPressed: onOpen,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEBEBEB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ver detalhes',
                      style: GoogleFonts.manrope(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    return InitiativeCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(action.title, style: _title()),
          const SizedBox(height: 6),
          Text(
            action.isActive
                ? '${action.volunteersLabel} · ${action.vacanciesLabel}'
                : 'Ação finalizada',
            style: _detail(),
          ),
          const SizedBox(height: 6),
          ScheduleLine(action: action, prefix: 'Data: '),
          const SizedBox(height: 12),
          AppCardActions(
            secondaryLabel: 'Ver detalhes',
            onSecondary: onOpen,
            primaryLabel: pending > 0
                ? 'Ver voluntários ($pending)'
                : 'Ver voluntários',
            primaryKey: Key('action_volunteers_${action.id}'),
            onPrimary: onVolunteers,
          ),
        ],
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

    return InitiativeCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(action.title, style: _title()),
          const SizedBox(height: 6),
          Text('Região: ${action.placeLabel}', style: _detail()),
          const SizedBox(height: 4),
          ScheduleLine(action: action),
          const SizedBox(height: 4),
          Text('Responsável: ${action.organizationName}', style: _detail()),
          const SizedBox(height: 12),
          AppCardActions(
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
        ],
      ),
    );
  }
}
