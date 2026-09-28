import 'package:http/http.dart' as http;

import '../network/api_requester.dart';
import 'need_tag.dart';

class TagsRepository {
  TagsRepository(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  static const _serverMessages = {
    'Tag already exists': 'Já existe uma necessidade com esse nome.',
    'Only admins can manage needs':
        'Só administradores podem gerenciar necessidades.',
  };

  static NeedTag _decode(http.Response response) =>
      NeedTag.fromJson(ApiRequester.decodeObject(response));

  Future<List<NeedTag>> getAll(String token) {
    return _api.request(
      HttpMethod.get,
      '/tag',
      token: token,
      errorMessage: 'Não foi possível carregar as necessidades.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          ApiRequester.decodeList(response).map(NeedTag.fromJson).toList(),
    );
  }

  Future<NeedTag> create(String name, String token) {
    return _api.request(
      HttpMethod.post,
      '/tag',
      token: token,
      body: {'name': name},
      errorMessage: 'Não foi possível criar a necessidade.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  Future<NeedTag> update(int id, String name, String token) {
    return _api.request(
      HttpMethod.put,
      '/tag/$id',
      token: token,
      body: {'name': name},
      errorMessage: 'Não foi possível salvar a necessidade.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  Future<void> delete(int id, String token) {
    return _api.request(
      HttpMethod.delete,
      '/tag/$id',
      token: token,
      errorMessage: 'Não foi possível excluir a necessidade.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (_) {},
    );
  }
}
