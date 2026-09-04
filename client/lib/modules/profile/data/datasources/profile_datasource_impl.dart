import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_config.dart';
import '../models/user_profile_model.dart';
import 'profile_datasource.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  const ProfileDatasourceImpl(this._client);

  final http.Client _client;

  @override
  Future<UserProfileModel> getCurrentUser(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/user/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AppException(
          'Sua sessão expirou. Entre novamente para continuar.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppException('Não foi possível carregar seu perfil.');
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const AppException('Resposta inválida recebida do servidor.');
      }

      return UserProfileModel.fromJson(json);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('Resposta inválida recebida do servidor.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível carregar seu perfil.');
    }
  }
}
