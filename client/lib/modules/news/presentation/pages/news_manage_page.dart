import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_view.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_store.dart';
import '../widgets/news_manage_card.dart';

class NewsManagePage extends StatefulWidget {
  const NewsManagePage({super.key, this.store, this.token});

  final NewsStore? store;
  final String? token;

  @override
  State<NewsManagePage> createState() => _NewsManagePageState();
}

class _NewsManagePageState extends State<NewsManagePage> {
  late final NewsStore _store;
  final _search = TextEditingController();
  String _query = '';
  bool _loaded = false;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<NewsStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _store.load(_token);
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _go(String route, [Object? arguments]) async {
    await Modular.to.pushNamed(route, arguments: arguments);
    if (mounted) await _load();
  }

  bool _matches(NewsArticle article) {
    final term = _query.trim().toLowerCase();
    return term.isEmpty ||
        [
          article.title,
          article.subtitle,
          article.content,
          article.locationLabel,
        ].any((text) => text.toLowerCase().contains(term));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final isEmpty =
            _loaded &&
            !_store.isLoading &&
            _store.errorMessage == null &&
            _store.articles.isEmpty;

        return AppPageScaffold(
          currentItem: AppNavigationItem.profile,
          floatingActionButton: FloatingActionButton(
            key: const Key('news_manage_create_fab'),
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            tooltip: 'Criar notícia',
            onPressed: () => _go(AppRoutes.newsForm),
            child: const Icon(Icons.add, size: 32),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: AppSearchField(
                  key: const Key('news_manage_search'),
                  controller: _search,
                  hintText: 'Nome, categoria, descrição',
                  onSearch: () => setState(() => _query = _search.text),
                ),
              ),
              if (isEmpty)
                const Expanded(
                  child: AppStatusView(
                    illustration: Image(
                      image: AssetImage('assets/illustrations/empty_news.png'),
                    ),
                    title: 'Nenhuma notícia publicada ainda',
                    message:
                        'Crie notícias para informar a comunidade sobre '
                        'campanhas, ações, eventos e atualizações da ONG.',
                  ),
                )
              else
                Expanded(
                  child: AppAsyncList<NewsArticle>(
                    items: _store.articles.where(_matches).toList(),
                    isLoading: _store.isLoading,
                    errorMessage: _store.errorMessage,
                    emptyMessage: 'Nenhuma notícia encontrada.',
                    onRefresh: _load,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                    itemBuilder: (_, article) => NewsManageCard(
                      key: Key('news_manage_card_${article.id}'),
                      article: article,
                      onOpen: () => _go(AppRoutes.newsManageDetail, article),
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
