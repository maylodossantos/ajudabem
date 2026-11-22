import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_status_view.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';
import '../stores/action_stores.dart';
import '../widgets/initiative_cards.dart';

class VolunteerActionsPage extends StatefulWidget {
  const VolunteerActionsPage({super.key, this.store, this.token});

  final OpenActionsStore? store;
  final String? token;

  @override
  State<VolunteerActionsPage> createState() => _VolunteerActionsPageState();
}

class _VolunteerActionsPageState extends State<VolunteerActionsPage> {
  late final OpenActionsStore _store;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<OpenActionsStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(token);
  }

  Future<void> _open(VolunteerAction action) async {
    await Modular.to.pushNamed(
      AppRoutes.actionDetail,
      arguments: InitiativeArgs(action.id),
    );
    if (mounted) await _load();
  }

  Future<void> _apply(VolunteerAction action) async {
    final token = _token;
    if (token == null) return;
    final ok = await _store.apply(action, token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? 'Candidatura enviada! Aguarde a ONG aceitar.'
          : _store.errorMessage ?? 'Não foi possível se candidatar.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.profile,
      body: Observer(
        builder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionTitle('Ações voluntárias'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Escolha uma ação e candidate-se. A ONG confirma a sua '
                    'participação.',
                    style: GoogleFonts.manrope(
                      color: AppColors.textSecondary,
                      fontSize: AppTextSize.small,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppAsyncList<VolunteerAction>(
                items: _store.visibleActions,
                isLoading: _store.isLoading,
                errorMessage: _store.errorMessage,
                emptyMessage: 'Nenhuma ação voluntária aberta no momento.',
                emptyView: const AppStatusView(
                  illustration: Image(
                    image: AssetImage(
                      'assets/illustrations/empty_volunteer_actions.png',
                    ),
                  ),
                  title: 'Nenhuma ação voluntária aberta no momento.',
                  message:
                      'Volte mais tarde e veja se surgiram novas '
                      'oportunidades para ajudar.',
                ),
                onRefresh: _load,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemBuilder: (_, action) => OpenActionCard(
                  action: action,
                  isApplying: _store.isApplying(action.id),
                  onOpen: () => _open(action),
                  onApply: () => _apply(action),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
