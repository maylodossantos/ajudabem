import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_info_card.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';
import '../stores/action_stores.dart';

class ActionDetailPage extends StatefulWidget {
  const ActionDetailPage({
    required this.args,
    super.key,
    this.store,
    this.token,
    this.links,
  });

  final InitiativeArgs args;
  final ActionDetailStore? store;
  final String? token;
  final ExternalLinkService? links;

  @override
  State<ActionDetailPage> createState() => _ActionDetailPageState();
}

class _ActionDetailPageState extends State<ActionDetailPage> {
  late final ActionDetailStore _store;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  ExternalLinkService get _links =>
      widget.links ?? Modular.get<ExternalLinkService>();

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<ActionDetailStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(widget.args.id, token);
  }

  Future<void> _run(
    Future<bool> Function(String token) change,
    String success,
  ) async {
    final token = _token;
    if (token == null) return;
    final ok = await change(token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok ? success : _store.errorMessage ?? 'Algo deu errado.',
    );
  }

  Future<void> _confirmThen(
    String title,
    String message,
    String confirm,
    Future<void> Function() then,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirm,
    );
    if (confirmed && mounted) await then();
  }

  Future<void> _edit(VolunteerAction action) async {
    final updated = await Modular.to.pushNamed<VolunteerAction>(
      AppRoutes.actionForm,
      arguments: action,
    );
    if (updated != null && mounted) await _load();
  }

  Widget? _bottomBar(VolunteerAction action) {
    void back() => Navigator.of(context).maybePop();

    if (widget.args.manage) {
      if (!action.isActive) return null;
      return AppBottomActions(
        secondaryLabel: 'Finalizar',
        secondaryKey: const Key('action_finish'),
        onSecondary: _store.isBusy
            ? null
            : () => _confirmThen(
                'Finalizar ação?',
                'Ela sai da lista de ações abertas para voluntários.',
                'Finalizar',
                () => _run(_store.finish, 'Ação finalizada.'),
              ),
        primaryLabel: 'Editar',
        primaryKey: const Key('action_edit'),
        onPrimary: () => _edit(action),
      );
    }

    return AppBottomActions(
      secondaryLabel: 'Voltar',
      onSecondary: back,
      primaryKey: const Key('action_primary'),
      isLoading: _store.isBusy,
      primaryLabel: switch (action.myApplication) {
        ApplicationStatus.accepted => 'Desistir',
        ApplicationStatus.pending => 'Cancelar candidatura',
        null => action.isFull ? 'Vagas esgotadas' : 'Candidatar',
      },
      onPrimary: !action.isActive
          ? null
          : switch (action.myApplication) {
              ApplicationStatus.accepted => () => _confirmThen(
                'Desistir da ação?',
                'Sua vaga ficará livre para outra pessoa.',
                'Desistir',
                () => _run(_store.withdraw, 'Você desistiu da ação.'),
              ),
              ApplicationStatus.pending => () => _run(
                _store.withdraw,
                'Candidatura cancelada.',
              ),
              null when action.isFull => null,
              null => () => _run(
                _store.apply,
                'Candidatura enviada! Aguarde a ONG aceitar.',
              ),
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final action = _store.current;

        return AppPageScaffold(
          currentItem: widget.args.manage
              ? AppNavigationItem.ong
              : AppNavigationItem.profile,
          bottomBar: action == null ? null : _bottomBar(action),
          body: action == null
              ? (_store.errorMessage != null && !_store.isLoading
                    ? AppErrorView(
                        message: _store.errorMessage!,
                        onRetry: _load,
                      )
                    : const Center(child: CircularProgressIndicator()))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _ActionBody(
                    action: action,
                    onEmail: (address) => _links.email(address),
                    onWhatsApp: (phone) => _links.openWhatsApp(phone),
                  ),
                ),
        );
      },
    );
  }
}

class _ActionBody extends StatelessWidget {
  const _ActionBody({
    required this.action,
    required this.onEmail,
    required this.onWhatsApp,
  });

  final VolunteerAction action;
  final Future<bool> Function(String) onEmail;
  final Future<bool> Function(String) onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final email = action.contactEmail;
    final phone = action.contactPhone;
    final sections = [
      ('Afazeres', action.tasks),
      ('Quem pode ajudar?', action.requirements),
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (email != null || phone != null) ...[
            Row(
              children: [
                if (email != null)
                  Expanded(
                    child: _ContactButton(
                      key: const Key('action_contact_email'),
                      label: 'Falar com a ONG',
                      background: const Color(0xFFEBEBEB),
                      onTap: () => onEmail(email),
                    ),
                  ),
                if (email != null && phone != null) const SizedBox(width: 12),
                if (phone != null && phone.isNotEmpty)
                  Expanded(
                    child: _ContactButton(
                      key: const Key('action_contact_whatsapp'),
                      label: 'Conversar via WhatsApp',
                      background: const Color(0xFFB7F5BE),
                      onTap: () => onWhatsApp(phone),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          AppInfoCard(
            title: action.title,
            child: AppFieldGrid(
              fields: [
                ('ONG:', action.organizationName),
                ('Vagas:', action.vacanciesLabel),
                ('Local:', action.addressLabel),
                ('Situação:', action.isActive ? 'Aberta' : 'Finalizada'),
                ('Data:', action.dateLabel),
                ('Horário:', action.scheduleLabel),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppInfoCard(
            title: 'Descrição',
            child: Text(
              action.description,
              style: GoogleFonts.manrope(fontSize: 14, height: 1.4),
            ),
          ),
          for (final (title, text) in sections)
            if (AppBulletList.linesOf(text) case final lines
                when lines.isNotEmpty) ...[
              const SizedBox(height: 14),
              AppInfoCard(
                title: title,
                child: AppBulletList(lines: lines),
              ),
            ],
          if (action.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            AppInfoCard(
              title: 'Observações',
              child: Text(
                action.notes,
                style: GoogleFonts.manrope(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.background,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
