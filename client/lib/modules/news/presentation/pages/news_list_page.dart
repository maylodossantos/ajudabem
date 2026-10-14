import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_item_actions_menu.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_segmented_tabs.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../initiatives/domain/entities/campaign.dart';
import '../../../initiatives/presentation/stores/campaign_stores.dart';
import '../../../initiatives/presentation/widgets/campaign_carousel.dart';
import '../../../initiatives/presentation/widgets/initiative_cards.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_store.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({
    super.key,
    this.store,
    this.profileStore,
    this.authToken,
    this.campaignsStore,
  });

  final NewsStore? store;
  final CampaignsFeedStore? campaignsStore;
  final ProfileStore? profileStore;
  final String? authToken;

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late final ProfileStore _profileStore;
  late final NewsStore _store;
  late final CampaignsFeedStore? _campaigns;
  bool _showCampaigns = false;
  bool _searching = false;
  String _query = '';
  final _search = TextEditingController();
  String? _token;

  @override
  void initState() {
    super.initState();
    final usingTestDoubles =
        widget.store != null || widget.profileStore != null;
    _profileStore = widget.profileStore ?? Modular.get<ProfileStore>();
    _store = widget.store ?? Modular.get<NewsStore>();
    _campaigns = usingTestDoubles
        ? widget.campaignsStore
        : (widget.campaignsStore ?? Modular.tryGet<CampaignsFeedStore>());
    _token = usingTestDoubles
        ? widget.authToken
        : (widget.authToken ?? Modular.get<LoginStore>().authToken);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch() => setState(() {
    _searching = !_searching;
    if (!_searching) {
      _search.clear();
      _query = '';
    }
  });

  bool _matches(List<String> texts) {
    final term = _query.trim().toLowerCase();
    return term.isEmpty ||
        texts.any((text) => text.toLowerCase().contains(term));
  }

  Future<void> _load() async {
    final token = _token;
    final loads = [_store.load(token), ?_campaigns?.load()];
    if (token != null && _profileStore.profile == null) {
      loads.add(_profileStore.load(token));
    }
    await Future.wait(loads);
  }

  void _openDetail(NewsArticle article) {
    Modular.to.pushNamed(AppRoutes.newsDetail, arguments: article);
  }

  void _openCampaign(Campaign campaign) {
    Modular.to.pushNamed(AppRoutes.campaignDetail, arguments: campaign.id);
  }

  void _openEdit(NewsArticle article) {
    Modular.to.pushNamed(AppRoutes.newsForm, arguments: article);
  }

  Future<void> _confirmDelete(NewsArticle article) async {
    final shouldDelete = await showAppConfirmDialog(
      context,
      title: 'Excluir notícia?',
      message: 'A notícia "${article.title}" será excluída permanentemente.',
      confirmLabel: 'Excluir',
    );

    if (!shouldDelete || !mounted) return;

    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final deleted = await _store.deleteArticle(article.id, token);
    if (!mounted) return;

    showAppSnackBar(
      context,
      deleted
          ? 'Notícia excluída com sucesso.'
          : _store.errorMessage ?? 'Não foi possível excluir a notícia.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AuthAppBar(showSearchButton: true, onSearch: _toggleSearch),
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
                final canPublish =
                    _profileStore.profile?.canPublishNews ?? false;
                final allCampaigns =
                    _campaigns?.campaigns ?? const <Campaign>[];
                final campaigns = allCampaigns
                    .where(
                      (campaign) => _matches([
                        campaign.title,
                        campaign.subtitle,
                        campaign.organizationName,
                      ]),
                    )
                    .toList();
                final articles = _store.articles
                    .where(
                      (article) => _matches([
                        article.title,
                        article.subtitle,
                        article.content,
                        article.locationLabel,
                      ]),
                    )
                    .toList();
                final showCampaigns = _showCampaigns && allCampaigns.isNotEmpty;
                final now = DateTime.now();

                Widget newsCard(
                  NewsArticle article, {
                  required bool featured,
                }) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NewsCard(
                    key: Key('news_card_${article.id}'),
                    article: article,
                    featured: featured,
                    when: article.createdAt == null
                        ? ''
                        : DateInputFormatter.relative(article.createdAt!, now),
                    canManage: canPublish,
                    isDeleting: _store.isDeleting(article.id),
                    onTap: () => _openDetail(article),
                    onEdit: () => _openEdit(article),
                    onDelete: () => _confirmDelete(article),
                  ),
                );

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      if (_searching) ...[
                        AppSearchField(
                          key: const Key('news_search_field'),
                          controller: _search,
                          hintText: 'Buscar notícias e campanhas',
                          onSearch: () => setState(() => _query = _search.text),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (allCampaigns.isNotEmpty && !_searching) ...[
                        const AppSectionTitle('Campanhas em andamento'),
                        const SizedBox(height: 12),
                        CampaignCarousel(
                          campaigns: allCampaigns.take(5).toList(),
                          onOpen: _openCampaign,
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (allCampaigns.isNotEmpty)
                        AppSegmentedTabs<bool>(
                          tabs: const [
                            (false, 'Notícias'),
                            (true, 'Campanhas'),
                          ],
                          selected: showCampaigns,
                          onSelected: (value) =>
                              setState(() => _showCampaigns = value),
                        )
                      else
                        const AppSectionTitle('Notícias'),
                      const SizedBox(height: 16),
                      if (showCampaigns)
                        if (campaigns.isEmpty)
                          const _ListState(
                            isLoading: false,
                            message: 'Nenhuma campanha encontrada.',
                          )
                        else
                          for (final campaign in campaigns)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CampaignCard(
                                campaign: campaign,
                                onOpen: () => _openCampaign(campaign),
                              ),
                            )
                      else if (articles.isEmpty)
                        _ListState(
                          isLoading: _store.isLoading,
                          message:
                              _store.errorMessage ??
                              (_query.isEmpty
                                  ? 'Nenhuma notícia publicada ainda.'
                                  : 'Nenhuma notícia encontrada.'),
                        )
                      else ...[
                        newsCard(articles.first, featured: true),
                        for (final article in articles.skip(1))
                          newsCard(article, featured: false),
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

class _ListState extends StatelessWidget {
  const _ListState({required this.isLoading, required this.message});

  final bool isLoading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF454545),
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.article,
    required this.featured,
    required this.when,
    required this.canManage,
    required this.isDeleting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final NewsArticle article;
  final bool featured;
  final String when;
  final bool canManage;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Widget _cover({required double radius, double aspectRatio = 1}) =>
      AppCoverImage(
        imageUrl: article.coverImage,
        aspectRatio: aspectRatio,
        borderRadius: BorderRadius.circular(radius),
        placeholder: const ColoredBox(
          color: Color(0xFFD9D9D9),
          child: Icon(Icons.newspaper, color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final title = Text(
      article.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.manrope(
        color: const Color(0xFF1B1B1B),
        fontSize: featured ? 16.5 : 14.5,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0,
      ),
    );
    final subtitle = article.subtitle.isEmpty
        ? null
        : Text(
            article.subtitle,
            maxLines: featured ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFF6B6B6B),
              fontSize: featured ? 13.5 : 12.5,
              height: 1.35,
              letterSpacing: 0,
            ),
          );
    final footer = _Footer(location: article.locationLabel, when: when);
    final menu = canManage
        ? AppItemActionsMenu(
            tooltip: 'Opções da notícia',
            isBusy: isDeleting,
            onEdit: onEdit,
            onDelete: onDelete,
          )
        : null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: featured
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cover(radius: 0, aspectRatio: 16 / 9),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              if (subtitle != null) ...[
                                const SizedBox(height: 6),
                                subtitle,
                              ],
                              const SizedBox(height: 10),
                              footer,
                            ],
                          ),
                        ),
                        menu ?? const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 78, child: _cover(radius: 12)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            subtitle,
                          ],
                          const SizedBox(height: 8),
                          footer,
                        ],
                      ),
                    ),
                    menu ?? const SizedBox(width: 8),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.location, required this.when});

  final String location;
  final String when;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.manrope(
      color: const Color(0xFF8A8A8A),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (location.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Color(0xFF8A8A8A),
              ),
              const SizedBox(width: 3),
              Text(location, style: style),
            ],
          ),
        if (when.isNotEmpty) Text(when, style: style),
      ],
    );
  }
}
