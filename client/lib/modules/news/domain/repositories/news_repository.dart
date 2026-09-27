import '../entities/news_article.dart';
import '../entities/news_form_params.dart';

abstract interface class NewsRepository {
  Future<List<NewsArticle>> getAll(String? token);

  Future<NewsArticle> create(NewsFormParams params, String token);

  Future<NewsArticle> update(int id, NewsFormParams params, String token);

  Future<void> delete(int id, String token);
}
