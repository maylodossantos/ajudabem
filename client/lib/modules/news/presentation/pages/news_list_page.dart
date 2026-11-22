import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_carousel.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../initiatives/domain/entities/campaign.dart';
import '../../../initiatives/presentation/stores/campaign_stores.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_store.dart';
import '../../domain/entities/news_category.dart';
import '../widgets/feed_item.dart';
import '../widgets/feed_list_card.dart';
import '../widgets/news_feature_cards.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({
    super.key,
    this.store,
    this.profileStore,
    this.authToken,
    this.campaignsStore,
    this.showCampaigns = false,
  });

  final NewsStore? store;
  final CampaignsFeedStore? campaignsStore;
  final ProfileStore? profileStore;
  final String? authToken;
  final bool showCampaigns;

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late final ProfileStore _profileStore;
  late final NewsStore _store;
  late final CampaignsFeedStore? _campaigns;
  late bool _showCampaigns = widget.showCampaigns;
  NewsCategory? _category;
  String? _token;

  static const _highlights = 3;
  static const _highlightHeight = 200.0;

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

  Future<void> _openEdit(NewsArticle article) async {
    final saved = await Modular.to.pushNamed<NewsArticle>(
      AppRoutes.newsForm,
      arguments: article,
    );
    if (saved != null && mounted) await _load();
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
      appBar: const AuthAppBar(showBackButton: true),
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
                final campaigns = _campaigns?.campaigns ?? const <Campaign>[];
                final category = _category;
                final showCampaigns = _showCampaigns && campaigns.isNotEmpty;
                final entries = FeedEntry.build(
                  articles: _store.articles,
                  campaigns: campaigns,
                  now: DateTime.now(),
                  category: category,
                  campaignsOnly: showCampaigns,
                );
                final highlights = entries.take(_highlights).toList();

                void open(FeedEntry entry) {
                  if (entry.campaign case final campaign?) {
                    _openCampaign(campaign);
                  } else if (entry.article case final article?) {
                    _openDetail(article);
                  }
                }

                Widget listCard(FeedEntry entry) {
                  final article = entry.article;
                  final canManage = canPublish && article != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: FeedListCard(
                      key: Key(entry.cardKey),
                      item: entry.item,
                      onTap: () => open(entry),
                      menuItemLabel: 'notícia',
                      isDeleting: canManage && _store.isDeleting(article.id),
                      onEdit: canManage ? () => _openEdit(article) : null,
                      onDelete: canManage
                          ? () => _confirmDelete(article)
                          : null,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      if (_store.articles.isNotEmpty ||
                          campaigns.isNotEmpty) ...[
                        NewsCategoryChips(
                          categories: newsCategoriesIn(_store.articles),
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
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      if (entries.isEmpty)
                        NewsListState(
                          isLoading: _store.isLoading,
                          message:
                              _store.errorMessage ??
                              (category == null
                                  ? 'Nenhuma notícia publicada ainda.'
                                  : 'Nenhuma notícia nessa categoria.'),
                        )
                      else ...[
                        const AppSectionTitle('Destaques'),
                        const SizedBox(height: AppSpacing.md),
                        AppCarousel(
                          key: ValueKey(
                            'feed_highlights_${showCampaigns}_${category?.name}',
                          ),
                          itemCount: highlights.length,
                          height: _highlightHeight,
                          itemBuilder: (_, index) => FeedHighlightCard(
                            key: Key(highlights[index].highlightKey),
                            item: highlights[index].item,
                            onTap: () => open(highlights[index]),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppSectionTitle(
                          showCampaigns
                              ? 'Campanhas em andamento'
                              : category == null
                              ? 'Últimas novidades'
                              : 'Últimas notícias',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final entry in entries) listCard(entry),
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

class NewsListState extends StatelessWidget {
  const NewsListState({
    required this.isLoading,
    required this.message,
    super.key,
  });

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
                  color: AppColors.textBody,
                  fontSize: AppTextSize.body,
                ),
              ),
      ),
    );
  }
}
