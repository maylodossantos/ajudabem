import 'package:http/http.dart' as http;

import '../../../../core/network/api_requester.dart';
import '../../domain/entities/news_form_params.dart';
import '../models/news_article_model.dart';
import 'news_datasource.dart';

class NewsDatasourceImpl implements NewsDatasource {
  NewsDatasourceImpl(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  @override
  Future<List<NewsArticleModel>> getAll(String? token) {
    return _api.request(
      HttpMethod.get,
      '/news',
      token: token,
      errorMessage: 'Não foi possível carregar as notícias.',
      useServerMessage: false,
      onSuccess: (response) => ApiRequester.decodeList(
        response,
      ).map(NewsArticleModel.fromJson).toList(),
    );
  }

  @override
  Future<NewsArticleModel> create(NewsFormParams params, String token) {
    return _api.request(
      HttpMethod.post,
      '/news',
      token: token,
      body: _requestBody(params),
      errorMessage: 'Não foi possível publicar a notícia.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          NewsArticleModel.fromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<NewsArticleModel> update(int id, NewsFormParams params, String token) {
    return _api.request(
      HttpMethod.put,
      '/news/$id',
      token: token,
      body: _requestBody(params),
      errorMessage: 'Não foi possível atualizar a notícia.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          NewsArticleModel.fromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<void> delete(int id, String token) {
    return _api.request(
      HttpMethod.delete,
      '/news/$id',
      token: token,
      errorMessage: 'Não foi possível excluir a notícia.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (_) {},
    );
  }

  Map<String, dynamic> _requestBody(NewsFormParams params) {
    return {
      'title': params.title,
      'subtitle': params.subtitle,
      'content': params.content,
      'cover_image': ?params.coverImage,
    };
  }
}
