import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../initiatives/initiatives_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import 'data/datasources/news_datasource.dart';
import 'data/datasources/news_datasource_impl.dart';
import 'data/repositories/news_repository_impl.dart';
import 'domain/entities/news_article.dart';
import 'domain/repositories/news_repository.dart';
import 'presentation/pages/news_detail_page.dart';
import 'presentation/pages/news_form_page.dart';
import 'presentation/pages/news_list_page.dart';
import 'presentation/stores/news_form_store.dart';
import 'presentation/stores/news_store.dart';

class NewsModule extends Module {
  @override
  List<Module> get imports => [CoreModule(), InitiativesModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<NewsDatasource>(NewsDatasourceImpl.new);
    i.addSingleton<NewsRepository>(NewsRepositoryImpl.new);
    i.add(NewsStore.new);
    i.add(NewsFormStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(AppRoutes.news, child: (_) => const NewsListPage());
    r.child(
      AppRoutes.newsDetail,
      child: (_) => NewsDetailPage(article: Modular.args.data as NewsArticle),
    );
    r.child(
      AppRoutes.newsForm,
      guards: [AuthGuard()],
      child: (_) => NewsFormPage(
        initialArticle: Modular.args.data is NewsArticle
            ? Modular.args.data as NewsArticle
            : null,
      ),
    );
  }
}
