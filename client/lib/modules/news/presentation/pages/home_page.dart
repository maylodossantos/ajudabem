import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_shortcut_tile.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../initiatives/domain/entities/campaign.dart';
import '../../../initiatives/domain/entities/volunteer_action.dart';
import '../../../initiatives/presentation/stores/action_stores.dart';
import '../../../initiatives/presentation/stores/campaign_stores.dart';
import '../../../initiatives/presentation/widgets/initiative_cards.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../stores/news_store.dart';
import '../../domain/entities/news_category.dart';
import '../widgets/feed_item.dart';
import '../widgets/news_feature_cards.dart';
import 'news_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.store,
    this.profileStore,
    this.campaignsStore,
    this.actionsStore,
    this.authToken,
  });

  final NewsStore? store;
  final ProfileStore? profileStore;
  final CampaignsFeedStore? campaignsStore;
  final OpenActionsStore? actionsStore;
  final String? authToken;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NewsStore _store;
  late final ProfileStore _profileStore;
  late final CampaignsFeedStore? _campaigns;
  late final OpenActionsStore? _actions;
  String? _token;
  NewsCategory? _category;
  bool _showCampaigns = false;

  static const _sectionGap = SizedBox(height: AppSpacing.xl);
  static const _titleGap = SizedBox(height: AppSpacing.md);
  static const _visibleNews = 10;
  static const _tileWidth = 240.0;
  static const _visibleCampaigns = 5;

  bool get _signedIn => _token != null;

  @override
  void initState() {
    super.initState();
    final usingTestDoubles =
        widget.store != null || widget.profileStore != null;
    _store = widget.store ?? Modular.get<NewsStore>();
    _profileStore = widget.profileStore ?? Modular.get<ProfileStore>();
    _campaigns = usingTestDoubles
        ? widget.campaignsStore
        : (widget.campaignsStore ?? Modular.tryGet<CampaignsFeedStore>());
    _actions = usingTestDoubles
        ? widget.actionsStore
        : (widget.actionsStore ?? Modular.tryGet<OpenActionsStore>());
    _token = usingTestDoubles
        ? widget.authToken
        : (widget.authToken ?? Modular.get<LoginStore>().authToken);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    await Future.wait([
      _store.load(token),
      ?_campaigns?.load(),
      if (token != null) ?_actions?.load(token),
      if (token != null && _profileStore.profile == null)
        _profileStore.load(token),
    ]);
  }

  void _push(String route, [Object? arguments]) {
    Modular.to.pushNamed(route, arguments: arguments);
  }

  void _signIn() => Modular.to.navigate(AppRoutes.auth);

  void _openEntry(FeedEntry entry) {
    if (entry.campaign case final campaign?) {
      _push(AppRoutes.campaignDetail, campaign.id);
    } else if (entry.article case final article?) {
      _push(AppRoutes.newsDetail, article);
    }
  }

  Future<void> _openAction(VolunteerAction action) async {
    await Modular.to.pushNamed(
      AppRoutes.actionDetail,
      arguments: InitiativeArgs(action.id),
    );
    if (mounted) await _load();
  }

  Future<void> _apply(VolunteerAction action) async {
    final token = _token;
    final actions = _actions;
    if (token == null || actions == null) return;
    final ok = await actions.apply(action, token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? 'Candidatura enviada! Aguarde a ONG aceitar.'
          : actions.errorMessage ?? 'Não foi possível se candidatar.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(),
      bottomNavigationBar: AppMainNavigation(
        key: const Key('news_bottom_navigation'),
        currentItem: AppNavigationItem.news,
        profileStore: _profileStore,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Observer(
              builder: (_) {
                final name = _profileStore.profile?.name.trim() ?? '';
                final campaigns = (_campaigns?.campaigns ?? const <Campaign>[])
                    .take(_visibleCampaigns)
                    .toList();
                final action = _signedIn ? _actions?.actions.firstOrNull : null;
                final featured = _store.articles.firstOrNull;
                final others = _store.articles.skip(1).toList();
                final category = _category;
                final showCampaigns = _showCampaigns && campaigns.isNotEmpty;
                final strip = FeedEntry.build(
                  articles: others,
                  campaigns: campaigns,
                  now: DateTime.now(),
                  category: category,
                  campaignsOnly: showCampaigns,
                ).take(_visibleNews).toList();

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      if (_signedIn)
                        _Greeting(firstName: name.split(' ').first)
                      else
                        _WelcomeCard(
                          onSignIn: _signIn,
                          onSignUp: () => _push(AppRoutes.register),
                        ),
                      _sectionGap,
                      _Shortcuts(
                        signedIn: _signedIn,
                        onIndicate: _signedIn
                            ? () =>
                                  _push(AppRoutes.vulnerablePersonRegistration)
                            : _signIn,
                        onHelpPoints: () =>
                            Modular.to.navigate(AppRoutes.helpPoints),
                        onVolunteer: _signedIn
                            ? () => _push(AppRoutes.volunteerActions)
                            : _signIn,
                      ),
                      if (action != null) ...[
                        _sectionGap,
                        _SectionHeader(
                          title: 'Ações voluntárias',
                          seeAllKey: const Key('home_actions_see_all'),
                          onSeeAll: () => _push(AppRoutes.volunteerActions),
                        ),
                        _titleGap,
                        OpenActionCard(
                          action: action,
                          isApplying: _actions?.isApplying(action.id) ?? false,
                          onOpen: () => _openAction(action),
                          onApply: () => _apply(action),
                        ),
                      ],
                      _sectionGap,
                      _SectionHeader(
                        title: 'Novidades',
                        seeAllKey: const Key('home_news_see_all'),
                        onSeeAll: () => _push(AppRoutes.newsAll, showCampaigns),
                      ),
                      _titleGap,
                      if (featured == null && campaigns.isEmpty)
                        NewsListState(
                          isLoading: _store.isLoading,
                          message:
                              _store.errorMessage ??
                              'Nenhuma notícia publicada ainda.',
                        )
                      else ...[
                        if (featured != null) ...[
                          FeedFeaturedCard(
                            key: Key('news_featured_${featured.id}'),
                            item: FeedItem.article(featured, DateTime.now()),
                            onTap: () => _push(AppRoutes.newsDetail, featured),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (others.isNotEmpty || campaigns.isNotEmpty) ...[
                          NewsCategoryChips(
                            categories: newsCategoriesIn(others),
                            selected: category,
                            onSelected: (value) => setState(() {
                              _category = value;
                              _showCampaigns = false;
                            }),
                            campaignsSelected: showCampaigns,
                            onCampaigns: campaigns.isEmpty
                                ? null
                                : () => setState(() => _showCampaigns = true),
                          ),
                          _titleGap,
                          _FeedStrip(
                            tileWidth: _tileWidth,
                            tiles: [
                              for (final entry in strip)
                                (
                                  key: entry.tileKey,
                                  item: entry.item,
                                  onTap: () => _openEntry(entry),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Text(
      firstName.isEmpty ? 'Olá!' : 'Olá, $firstName!',
      style: GoogleFonts.manrope(
        color: Theme.of(context).colorScheme.primary,
        fontSize: AppTextSize.display,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onSignIn, required this.onSignUp});

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_welcome_card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seja bem-vindo ao AjudaBem!',
            style: GoogleFonts.manrope(
              color: Theme.of(context).colorScheme.primary,
              fontSize: AppTextSize.title,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Encontre pontos de apoio, acompanhe campanhas e indique pessoas '
            'que precisam de ajuda para as ONGs da sua cidade.',
            style: GoogleFonts.manrope(
              color: AppColors.textBody,
              fontSize: AppTextSize.body,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCardActions(
            secondaryLabel: 'Entrar',
            onSecondary: onSignIn,
            primaryLabel: 'Criar conta',
            primaryKey: const Key('home_sign_up_button'),
            onPrimary: onSignUp,
          ),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({
    required this.signedIn,
    required this.onIndicate,
    required this.onHelpPoints,
    required this.onVolunteer,
  });

  final bool signedIn;
  final VoidCallback onIndicate;
  final VoidCallback onHelpPoints;
  final VoidCallback onVolunteer;

  @override
  Widget build(BuildContext context) {
    final indicate = AppShortcutTile(
      key: const Key('home_shortcut_indicate'),
      iconAsset: AppIcons.indicatePerson,
      label: 'Indicar pessoa',
      locked: !signedIn,
      onTap: onIndicate,
    );
    final helpPoints = AppShortcutTile(
      key: const Key('home_shortcut_help_points'),
      iconAsset: AppIcons.helpPoints,
      label: 'Pontos de ajuda',
      onTap: onHelpPoints,
    );
    final volunteer = AppShortcutTile(
      key: const Key('home_shortcut_volunteer'),
      iconAsset: AppIcons.beVolunteer,
      label: 'Ser voluntário',
      locked: !signedIn,
      onTap: onVolunteer,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          for (final tile
              in signedIn
                  ? [indicate, helpPoints, volunteer]
                  : [helpPoints, indicate, volunteer])
            Expanded(child: tile),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.seeAllKey,
    required this.onSeeAll,
  });

  final String title;
  final Key seeAllKey;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppSectionTitle(title)),
        TextButton(
          key: seeAllKey,
          onPressed: onSeeAll,
          child: const Text('Ver todas'),
        ),
      ],
    );
  }
}

typedef _FeedTile = ({String key, FeedItem item, VoidCallback onTap});

class _FeedStrip extends StatelessWidget {
  const _FeedStrip({required this.tiles, required this.tileWidth});

  final List<_FeedTile> tiles;
  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) {
      return const NewsListState(
        isLoading: false,
        message: 'Nenhuma notícia nessa categoria.',
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: tileWidth,
                child: FeedTileCard(
                  key: Key(tile.key),
                  item: tile.item,
                  onTap: tile.onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
