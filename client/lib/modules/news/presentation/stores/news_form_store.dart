import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/stores/image_upload_store.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_form_params.dart';
import '../../domain/repositories/news_repository.dart';

part 'news_form_store.g.dart';

class NewsFormStore = NewsFormStoreBase with _$NewsFormStore;

abstract class NewsFormStoreBase with Store {
  NewsFormStoreBase(this._repository, ImageUploadService imageUploadService)
    : cover = ImageUploadStore(imageUploadService);

  final NewsRepository _repository;
  final ImageUploadStore cover;

  @observable
  int? articleId;

  @observable
  String title = '';

  @observable
  String subtitle = '';

  @observable
  String content = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get isEditing => articleId != null;

  @computed
  bool get canSubmit =>
      title.trim().isNotEmpty &&
      content.trim().isNotEmpty &&
      !isLoading &&
      !cover.isUploading;

  @action
  void populate(NewsArticle article) {
    articleId = article.id;
    title = article.title;
    subtitle = article.subtitle;
    content = article.content;
    cover.setImageUrl(article.coverImage);
  }

  @action
  void setTitle(String value) => title = value;

  @action
  void setSubtitle(String value) => subtitle = value;

  @action
  void setContent(String value) => content = value;

  @action
  Future<bool> submit(String token) async {
    if (!canSubmit) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final params = NewsFormParams(
        title: title.trim(),
        subtitle: subtitle.trim(),
        content: content.trim(),
        coverImage: cover.imageUrl,
      );

      final id = articleId;
      if (id == null) {
        await _repository.create(params, token);
      } else {
        await _repository.update(id, params, token);
      }
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível salvar a notícia.';
      return false;
    } finally {
      isLoading = false;
    }
  }
}
