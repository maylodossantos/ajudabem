import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_form_params.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._datasource);

  final NewsDatasource _datasource;

  @override
  Future<List<NewsArticle>> getAll(String? token) async {
    final models = await _datasource.getAll(token);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<NewsArticle> create(NewsFormParams params, String token) async {
    final model = await _datasource.create(params, token);
    return model.toEntity();
  }

  @override
  Future<NewsArticle> update(
    int id,
    NewsFormParams params,
    String token,
  ) async {
    final model = await _datasource.update(id, params, token);
    return model.toEntity();
  }

  @override
  Future<void> delete(int id, String token) {
    return _datasource.delete(id, token);
  }
}
