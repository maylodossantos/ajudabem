import 'package:http/http.dart' as http;

import '../../../../core/network/api_requester.dart';
import '../../domain/entities/create_assisted_person_params.dart';
import '../models/assisted_person_model.dart';
import 'assisted_person_datasource.dart';

class AssistedPersonDatasourceImpl implements AssistedPersonDatasource {
  AssistedPersonDatasourceImpl(http.Client client)
    : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  static const _notAuthorMessages = {
    403: 'Só quem fez o cadastro pode alterá-lo.',
  };

  @override
  Future<List<AssistedPersonModel>> getAll(String token) {
    return _api.request(
      HttpMethod.get,
      '/assisted-person',
      token: token,
      errorMessage: 'Não foi possível carregar os cadastros.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) => ApiRequester.decodeList(
        response,
      ).map(AssistedPersonModel.fromJson).toList(),
    );
  }

  @override
  Future<AssistedPersonModel> create(
    CreateAssistedPersonParams params,
    String token,
  ) {
    return _api.request(
      HttpMethod.post,
      '/assisted-person',
      token: token,
      body: _requestBody(params),
      errorMessage: 'Não foi possível concluir o cadastro.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          AssistedPersonModel.fromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<AssistedPersonModel> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) {
    return _api.request(
      HttpMethod.put,
      '/assisted-person/$id',
      token: token,
      body: _requestBody(params),
      errorMessage: 'Não foi possível atualizar o cadastro.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      statusMessages: _notAuthorMessages,
      onSuccess: (response) =>
          AssistedPersonModel.fromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<void> delete(int id, String token) {
    return _api.request(
      HttpMethod.delete,
      '/assisted-person/$id',
      token: token,
      errorMessage: 'Não foi possível excluir o cadastro.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      statusMessages: _notAuthorMessages,
      onSuccess: (_) {},
    );
  }

  Map<String, dynamic> _requestBody(CreateAssistedPersonParams params) {
    return {
      'full_name': params.fullName,
      'age': params.age,
      'gender': params.gender,
      'tagIds': params.tagIds,
      'notes': params.notes,
      'street': params.street,
      'number': params.number,
      'neighborhood': params.neighborhood,
      'city': params.city,
      'state': params.state,
      'zip_code': params.zipCode,
      'country': params.country,
    };
  }
}
