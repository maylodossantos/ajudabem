import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_item_actions_menu.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_store.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({
    super.key,
    this.store,
    this.profileStore,
    this.authToken,
  });

  final NewsStore? store;
  final ProfileStore? profileStore;
  final String? authToken;

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late final ProfileStore _profileStore;
  late final NewsStore _store;
  String? _token;

  @override
  void initState() {
    super.initState();
    final usingTestDoubles =
        widget.store != null || widget.profileStore != null;
    _profileStore = widget.profileStore ?? Modular.get<ProfileStore>();
    _store = widget.store ?? Modular.get<NewsStore>();
    // News is readable while signed out, so a null token is a real, valid
    // state - not "not provided yet". Widget tests that inject fakes own the
    // token directly (including passing null for "anonymous") instead of
    // falling back to Modular, which they don't set up.
    _token = usingTestDoubles
        ? widget.authToken
        : (widget.authToken ?? Modular.get<LoginStore>().authToken);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    final loads = [_store.load(token)];
    if (token != null && _profileStore.profile == null) {
      loads.add(_profileStore.load(token));
    }
    await Future.wait(loads);
  }

  void _openDetail(NewsArticle article) {
    Modular.to.pushNamed(AppRoutes.newsDetail, arguments: article);
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
    return Observer(
      builder: (_) {
        final canPublish = _profileStore.profile?.canPublishNews ?? false;

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
                constraints: const BoxConstraints(maxWidth: 390),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle('Notícias'),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Observer(
                          builder: (_) => AppAsyncList(
                            items: _store.articles,
                            isLoading: _store.isLoading,
                            errorMessage: _store.errorMessage,
                            emptyMessage: 'Nenhuma notícia publicada ainda.',
                            onRefresh: _load,
                            itemBuilder: (_, article) => Observer(
                              builder: (_) => _NewsCard(
                                key: Key('news_card_${article.id}'),
                                article: article,
                                canManage: canPublish,
                                isDeleting: _store.isDeleting(article.id),
                                onTap: () => _openDetail(article),
                                onEdit: () => _openEdit(article),
                                onDelete: () => _confirmDelete(article),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.article,
    required this.canManage,
    required this.isDeleting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final NewsArticle article;
  final bool canManage;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCoverImage(imageUrl: article.coverImage),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF232323),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        if (article.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            article.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF454545),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                        if (article.authorName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Por ${article.authorName}',
                            style: GoogleFonts.manrope(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (canManage)
                    AppItemActionsMenu(
                      tooltip: 'Opções da notícia',
                      isBusy: isDeleting,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
