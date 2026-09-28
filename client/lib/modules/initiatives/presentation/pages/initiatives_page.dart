import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_view.dart';
import '../../../../core/widgets/app_text_tabs.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';
import '../stores/initiatives_store.dart';
import '../widgets/initiative_cards.dart';

class InitiativesPage extends StatefulWidget {
  const InitiativesPage({super.key, this.store, this.token});

  final InitiativesStore? store;
  final String? token;

  @override
  State<InitiativesPage> createState() => _InitiativesPageState();
}

class _InitiativesPageState extends State<InitiativesPage> {
  late final InitiativesStore _store;
  final _search = TextEditingController();

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<InitiativesStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(token);
  }

  Future<void> _go(String route, [Object? arguments]) async {
    await Modular.to.pushNamed(route, arguments: arguments);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final campaignsTab = _store.tab == InitiativeTab.campaigns;

        return AppPageScaffold(
          currentItem: AppNavigationItem.ong,
          floatingActionButton: _store.isEmpty
              ? FloatingActionButton(
                  key: const Key('initiatives_create_fab'),
                  shape: const CircleBorder(),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  tooltip: 'Criar iniciativa',
                  onPressed: () => _go(AppRoutes.initiativeChooser),
                  child: const Icon(Icons.add, size: 32),
                )
              : null,
          bottomBar: _store.isEmpty || !_store.loaded
              ? null
              : AppPrimaryButton(
                  key: const Key('initiatives_create_button'),
                  label: campaignsTab ? 'Criar campanha' : 'Criar Ação',
                  onPressed: () => _go(
                    campaignsTab
                        ? AppRoutes.campaignForm
                        : AppRoutes.actionForm,
                  ),
                ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: AppSearchField(
                  controller: _search,
                  hintText: 'Nome, categoria, descrição',
                  onSearch: () => _store.setSearch(_search.text),
                ),
              ),
              if (_store.isEmpty)
                const Expanded(
                  child: AppStatusView(
                    illustration: Image(
                      image: AssetImage(
                        'assets/illustrations/campaign_megaphone.png',
                      ),
                    ),
                    title: 'Nenhuma iniciativa criada ainda',
                    message:
                        'Crie campanhas e ações para mobilizar pessoas, '
                        'organizar voluntários e ajudar quem precisa.',
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: AppTextTabs<InitiativeTab>(
                    tabs: const [
                      (InitiativeTab.campaigns, 'Campanhas'),
                      (InitiativeTab.actions, 'Ações'),
                    ],
                    selected: _store.tab,
                    onSelected: _store.setTab,
                  ),
                ),
                Expanded(
                  child: campaignsTab
                      ? AppAsyncList<Campaign>(
                          items: _store.visibleCampaigns,
                          isLoading: _store.isLoading,
                          errorMessage: _store.errorMessage,
                          emptyMessage: 'Nenhuma campanha criada ainda.',
                          onRefresh: _load,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemBuilder: (_, campaign) => CampaignCard(
                            campaign: campaign,
                            onOpen: () => _go(
                              AppRoutes.campaignDetail,
                              InitiativeArgs(campaign.id, manage: true),
                            ),
                          ),
                        )
                      : AppAsyncList<VolunteerAction>(
                          items: _store.visibleActions,
                          isLoading: _store.isLoading,
                          errorMessage: _store.errorMessage,
                          emptyMessage: 'Nenhuma ação criada ainda.',
                          onRefresh: _load,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemBuilder: (_, action) => ManagedActionCard(
                            action: action,
                            onOpen: () => _go(
                              AppRoutes.actionDetail,
                              InitiativeArgs(action.id, manage: true),
                            ),
                            onVolunteers: () =>
                                _go(AppRoutes.actionVolunteers, action.id),
                          ),
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
