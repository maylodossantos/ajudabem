import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/money_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_cover_detail.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../stores/campaign_stores.dart';

String textOf(Campaign campaign) {
  final goal = campaign.goalAmount;
  final deadline = campaign.deadline;
  final left = campaign.deadlineLabel(DateTime.now()).replaceAll('.', '');
  return [
    campaign.description.trim(),
    if (campaign.donationInfo.trim().isNotEmpty)
      'Você pode contribuir de diferentes formas:\n\n'
          '${campaign.donationInfo.trim()}',
    [
      if (goal != null) 'Meta: R\$ ${MoneyInputFormatter.display(goal)}',
      if (deadline != null)
        'Prazo: ${DateInputFormatter.display(deadline)} '
            '(${left.toLowerCase()})',
    ].join('\n'),
  ].where((part) => part.isNotEmpty).join('\n\n');
}

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
              : AppCoverDetail(
                  imageUrl: campaign.coverImage,
                  caption: campaign.organizationName,
                  title: campaign.title,
                  subtitle: campaign.subtitle,
                  body: textOf(campaign),
                  placeholderIcon: Icons.campaign_outlined,
                ),
        );
      },
    );
  }
}
