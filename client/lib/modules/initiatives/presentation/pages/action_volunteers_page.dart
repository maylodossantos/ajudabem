import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';
import '../stores/action_stores.dart';
import '../widgets/initiative_cards.dart';

class ActionVolunteersPage extends StatefulWidget {
  const ActionVolunteersPage({
    required this.actionId,
    super.key,
    this.store,
    this.token,
    this.links,
  });

  final int actionId;
  final VolunteersStore? store;
  final String? token;
  final ExternalLinkService? links;

  @override
  State<ActionVolunteersPage> createState() => _ActionVolunteersPageState();
}

class _ActionVolunteersPageState extends State<ActionVolunteersPage> {
  late final VolunteersStore _store;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<VolunteersStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(widget.actionId, token);
  }

  Future<void> _accept(VolunteerApplication application) async {
    final token = _token;
    if (token == null) return;
    final ok = await _store.accept(application, token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? '${application.name} foi aceito(a).'
          : _store.errorMessage ?? 'Não foi possível aceitar.',
    );
  }

  Future<void> _talk(VolunteerApplication application) async {
    final phone = application.phone;
    if (phone == null || phone.isEmpty) {
      showAppSnackBar(context, 'Este voluntário não informou telefone.');
      return;
    }
    await (widget.links ?? Modular.get<ExternalLinkService>()).openWhatsApp(
      phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final action = _store.current;

        return AppPageScaffold(
          currentItem: AppNavigationItem.ong,
          bottomBar: AppBottomActions(
            secondaryLabel: 'Voltar',
            onSecondary: () => Navigator.of(context).maybePop(),
            primaryLabel: 'Visualizar',
            onPrimary: () => Modular.to.pushNamed(
              AppRoutes.actionDetail,
              arguments: InitiativeArgs(widget.actionId, manage: true),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (action != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: _Header(
                    action: action,
                    accepted: _store.acceptedCount,
                  ),
                ),
              Expanded(
                child: AppAsyncList<VolunteerApplication>(
                  items: _store.volunteers,
                  isLoading: _store.isLoading,
                  errorMessage: _store.errorMessage,
                  emptyMessage: 'Ninguém se candidatou ainda.',
                  onRefresh: _load,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemBuilder: (_, application) => _VolunteerCard(
                    application: application,
                    isAccepting: _store.isAccepting(application.id),
                    canAccept:
                        (action?.isActive ?? false) &&
                        _store.acceptedCount < (action?.volunteersNeeded ?? 0),
                    onTalk: () => _talk(application),
                    onAccept: () => _accept(application),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.action, required this.accepted});

  final VolunteerAction action;
  final int accepted;

  @override
  Widget build(BuildContext context) {
    final needed = action.volunteersNeeded;

    return InitiativeCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action.title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ScheduleLine(action: action),
          const SizedBox(height: 6),
          Text(
            '$accepted de $needed voluntários',
            style: GoogleFonts.manrope(fontSize: 13.5),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: needed == 0 ? 0 : (accepted / needed).clamp(0, 1),
              minHeight: 8,
              backgroundColor: const Color(0xFFEBEBEB),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({
    required this.application,
    required this.isAccepting,
    required this.canAccept,
    required this.onTalk,
    required this.onAccept,
  });

  final VolunteerApplication application;
  final bool isAccepting;
  final bool canAccept;
  final VoidCallback onTalk;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return InitiativeCardShell(
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(radius: 32, imageUrl: application.profileImage),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  application.name,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCardActions(
            secondaryLabel: 'Conversar',
            onSecondary: onTalk,
            primaryLabel: application.isAccepted ? 'Aceito' : 'Aceitar',
            primaryKey: Key('accept_volunteer_${application.id}'),
            primaryDone: application.isAccepted,
            isLoading: isAccepting,
            onPrimary: canAccept ? onAccept : null,
          ),
        ],
      ),
    );
  }
}
