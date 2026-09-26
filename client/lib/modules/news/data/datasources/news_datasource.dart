import '../../domain/entities/news_form_params.dart';
import '../models/news_article_model.dart';

abstract interface class NewsDatasource {
  Future<List<NewsArticleModel>> getAll(String? token);

  Future<NewsArticleModel> create(NewsFormParams params, String token);

  Future<NewsArticleModel> update(int id, NewsFormParams params, String token);

  Future<void> delete(int id, String token);
}
