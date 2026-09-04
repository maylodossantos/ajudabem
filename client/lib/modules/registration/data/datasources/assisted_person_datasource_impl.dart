import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/entities/create_assisted_person_params.dart';
import '../models/assisted_person_model.dart';
import 'assisted_person_datasource.dart';

class AssistedPersonDatasourceImpl implements AssistedPersonDatasource {
  const AssistedPersonDatasourceImpl(this._client);

  final http.Client _client;

  @override
  Future<List<AssistedPersonModel>> getAll(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/assisted-person'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AppException(
          'Sua sessão expirou. Entre novamente para continuar.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(_errorMessage(response));
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! List<dynamic>) {
        throw const AppException('Resposta inválida recebida do servidor.');
      }

      return json
          .whereType<Map<String, dynamic>>()
          .map(AssistedPersonModel.fromJson)
          .toList();
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('Resposta inválida recebida do servidor.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível carregar os cadastros.');
    }
  }

  @override
  Future<AssistedPersonModel> create(
    CreateAssistedPersonParams params,
    String token,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/assisted-person'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_requestBody(params)),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AppException(
          'Sua sessão expirou. Entre novamente para continuar.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(_errorMessage(response));
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const AppException('Resposta inválida recebida do servidor.');
      }

      return AssistedPersonModel.fromJson(json);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('Resposta inválida recebida do servidor.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível concluir o cadastro.');
    }
  }

  @override
  Future<AssistedPersonModel> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}/assisted-person/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_requestBody(params)),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AppException(
          'Sua sessão expirou. Entre novamente para continuar.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(_errorMessage(response));
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const AppException('Resposta inválida recebida do servidor.');
      }

      return AssistedPersonModel.fromJson(json);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('Resposta inválida recebida do servidor.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível atualizar o cadastro.');
    }
  }

  @override
  Future<void> delete(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/assisted-person/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AppException(
          'Sua sessão expirou. Entre novamente para continuar.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(_errorMessage(response));
      }
    } on AppException {
      rethrow;
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível excluir o cadastro.');
    }
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

  String _errorMessage(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic>) {
        final message = json['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } on FormatException {
      // Uses the fallback message below.
    }

    return 'Não foi possível concluir o cadastro.';
  }
}
