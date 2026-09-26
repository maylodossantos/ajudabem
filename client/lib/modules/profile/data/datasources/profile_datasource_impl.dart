import 'package:http/http.dart' as http;

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/network/api_requester.dart';
import '../../../../core/network/server_messages.dart';
import '../models/user_profile_model.dart';
import 'profile_datasource.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  ProfileDatasourceImpl(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401, 403};

  @override
  Future<UserProfileModel> getCurrentUser(String token) {
    return _api.request(
      HttpMethod.get,
      '/user/me',
      token: token,
      errorMessage: 'Não foi possível carregar seu perfil.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          UserProfileModel.fromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<UserProfileModel> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  }) {
    return _api.request(
      HttpMethod.put,
      '/user/me',
      token: token,
      body: {
        'name': ?name,
        'phone': ?phone,
        'profileImage': ?profileImage,
        'cpf': ?cpf,
        if (birthDate != null) 'birthDate': DateInputFormatter.toIso(birthDate),
      },
      errorMessage: 'Não foi possível salvar as alterações do perfil.',
      serverMessages: ServerMessages.userConflicts,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          UserProfileModel.fromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<void> deleteAccount(String token) {
    return _api.request(
      HttpMethod.delete,
      '/user/me',
      token: token,
      errorMessage: 'Não foi possível excluir sua conta.',
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (_) {},
    );
  }
}
