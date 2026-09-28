import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/money_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_status_pill.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../stores/campaign_stores.dart';

class CampaignDetailPage extends StatefulWidget {
  const CampaignDetailPage({
    required this.args,
    super.key,
    this.store,
    this.token,
  });

  final InitiativeArgs args;
  final CampaignDetailStore? store;
  final String? token;

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  late final CampaignDetailStore _store;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<CampaignDetailStore>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _store.load(widget.args.id),
    );
  }

  Future<void> _finish() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Finalizar campanha?',
      message: 'Ela deixará de aparecer para as pessoas no AjudaBem.',
      confirmLabel: 'Finalizar',
    );
    final token = _token;
    if (!confirmed || token == null || !mounted) return;
    final success = await _store.finish(token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      success
          ? 'Campanha finalizada.'
          : _store.errorMessage ?? 'Não foi possível finalizar.',
    );
  }

  Future<void> _edit(Campaign campaign) async {
    final updated = await Modular.to.pushNamed<Campaign>(
      AppRoutes.campaignForm,
      arguments: campaign,
    );
    if (updated != null) _store.show(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final campaign = _store.campaign;
        final manage = widget.args.manage && (campaign?.isActive ?? false);

        return AppPageScaffold(
          currentItem: widget.args.manage
              ? AppNavigationItem.ong
              : AppNavigationItem.news,
          maxWidth: 560,
          bottomBar: manage
              ? AppBottomActions(
                  secondaryLabel: 'Finalizar',
                  secondaryKey: const Key('campaign_finish'),
                  onSecondary: _store.isFinishing ? null : _finish,
                  primaryLabel: 'Editar',
                  primaryKey: const Key('campaign_edit'),
                  onPrimary: () => _edit(campaign!),
                )
              : null,
          body: campaign == null
              ? (_store.errorMessage != null && !_store.isLoading
                    ? AppErrorView(
                        message: _store.errorMessage!,
                        onRetry: () => _store.load(widget.args.id),
                      )
                    : const Center(child: CircularProgressIndicator()))
              : _CampaignBody(campaign: campaign),
        );
      },
    );
  }
}

class _CampaignBody extends StatelessWidget {
  const _CampaignBody({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final body = GoogleFonts.manrope(
      color: const Color(0xFF232323),
      fontSize: 15,
      height: 1.45,
      letterSpacing: 0,
    );
    final cover = campaign.coverImage;
    final goal = campaign.goalAmount;
    final deadline = campaign.deadline;

    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            color: const Color(0xFFA2A2A2),
            child: cover == null || cover.isEmpty
                ? const Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: Colors.white,
                  )
                : Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 170, 20, 20),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.organizationName,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF454545),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  campaign.title,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF232323),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStatusPill(
                      label: campaign.category.label,
                      color: Theme.of(context).colorScheme.primary,
                      background: const Color(0xFFCFF2EC),
                    ),
                    AppStatusPill(
                      label: campaign.deadlineLabel(DateTime.now()),
                      color: const Color(0xFF454545),
                      background: const Color(0xFFEBEBEB),
                    ),
                  ],
                ),
                if (campaign.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    campaign.subtitle,
                    style: body.copyWith(color: const Color(0xFFA2A2A2)),
                  ),
                ],
                const SizedBox(height: 16),
                Text(campaign.description, style: body),
                if (goal != null || deadline != null) ...[
                  const SizedBox(height: 16),
                  if (goal != null)
                    Text(
                      'Meta: R\$ ${MoneyInputFormatter.display(goal)}',
                      style: body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  if (deadline != null)
                    Text(
                      'Prazo: ${DateInputFormatter.display(deadline)}',
                      style: body.copyWith(fontWeight: FontWeight.w700),
                    ),
                ],
                if (campaign.donationInfo.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Como ajudar',
                    style: body.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(campaign.donationInfo, style: body),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
