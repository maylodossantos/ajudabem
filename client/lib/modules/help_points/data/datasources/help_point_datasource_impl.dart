import 'package:http/http.dart' as http;

import '../../../../core/network/api_requester.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_form_params.dart';
import '../models/help_point_model.dart';
import 'help_point_datasource.dart';

class HelpPointDatasourceImpl implements HelpPointDatasource {
  HelpPointDatasourceImpl(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  static HelpPoint _decode(http.Response response) =>
      HelpPointModel.fromJson(ApiRequester.decodeObject(response));

  @override
  Future<List<HelpPoint>> getAll() {
    return _api.request(
      HttpMethod.get,
      '/help-point',
      errorMessage: 'Não foi possível carregar os pontos de ajuda.',
      useServerMessage: false,
      onSuccess: (response) => ApiRequester.decodeList(
        response,
      ).map(HelpPointModel.fromJson).toList(),
    );
  }

  @override
  Future<HelpPoint> create(HelpPointFormParams params, String token) {
    return _api.request(
      HttpMethod.post,
      '/help-point',
      token: token,
      body: HelpPointModel.toJson(params),
      errorMessage: 'Não foi possível cadastrar o ponto de ajuda.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  @override
  Future<HelpPoint> update(int id, HelpPointFormParams params, String token) {
    return _api.request(
      HttpMethod.put,
      '/help-point/$id',
      token: token,
      body: HelpPointModel.toJson(params),
      errorMessage: 'Não foi possível salvar o ponto de ajuda.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  @override
  Future<void> delete(int id, String token) {
    return _api.request(
      HttpMethod.delete,
      '/help-point/$id',
      token: token,
      errorMessage: 'Não foi possível excluir o ponto de ajuda.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (_) {},
    );
  }
}
