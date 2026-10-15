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

  NewsArticle? savedArticle;

  @observable
  int? articleId;

  @observable
  String title = '';

  @observable
  String subtitle = '';

  @observable
  String content = '';

  @observable
  String city = '';

  @observable
  String state = 'PR';

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
    city = article.city;
    state = article.state.isEmpty ? 'PR' : article.state;
    cover.setImageUrl(article.coverImage);
  }

  @action
  void setTitle(String value) => title = value;

  @action
  void setSubtitle(String value) => subtitle = value;

  @action
  void setContent(String value) => content = value;

  @action
  void setCity(String value) => city = value;

  @action
  void setState(String value) => state = value;

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
        city: city,
        state: state,
      );

      final id = articleId;
      savedArticle = id == null
          ? await _repository.create(params, token)
          : await _repository.update(id, params, token);
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
