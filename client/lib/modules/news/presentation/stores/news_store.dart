import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';

part 'news_store.g.dart';

class NewsStore = NewsStoreBase with _$NewsStore;

abstract class NewsStoreBase with Store {
  NewsStoreBase(this._repository);

  final NewsRepository _repository;

  @observable
  List<NewsArticle> articles = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Set<int> deletingIds = {};

  @action
  Future<void> load(String? token) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      articles = await _repository.getAll(token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar as notícias.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> deleteArticle(int id, String token) async {
    deletingIds = {...deletingIds, id};
    errorMessage = null;

    try {
      await _repository.delete(id, token);
      articles = articles.where((article) => article.id != id).toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível excluir a notícia.';
      return false;
    } finally {
      deletingIds = Set<int>.from(deletingIds)..remove(id);
    }
  }

  bool isDeleting(int id) => deletingIds.contains(id);
}
