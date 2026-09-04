import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/entities/register_user_params.dart';
import '../../domain/entities/sign_in_params.dart';
import '../models/auth_session_model.dart';
import 'auth_datasource.dart';

class AuthDatasourceImpl implements AuthDatasource {
  AuthDatasourceImpl(this._client);

  final http.Client _client;

  @override
  Future<AuthSessionModel> signIn(SignInParams params) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': params.email, 'password': params.password}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppException(
          'Não foi possível entrar. Confira seu e-mail e sua senha.',
        );
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const AppException('E-mail ou senha inválidos.');
      }

      final session = AuthSessionModel.fromJson(json);
      if (session.token.isEmpty) {
        throw const AppException('E-mail ou senha inválidos.');
      }

      return session;
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('E-mail ou senha inválidos.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível entrar.');
    }
  }

  @override
  Future<AuthSessionModel> register(RegisterUserParams params) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': params.name,
          'email': params.email,
          'phone': params.phone,
          'password': params.password,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(_errorMessage(response));
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const AppException('Resposta inválida recebida do servidor.');
      }

      final session = AuthSessionModel.fromJson(json);
      if (session.token.isEmpty) {
        throw const AppException('O servidor não retornou um token de acesso.');
      }

      return session;
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('Resposta inválida recebida do servidor.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor. Verifique se a API está ativa.',
      );
    } catch (_) {
      throw const AppException('Não foi possível realizar o cadastro.');
    }
  }

  String _errorMessage(http.Response response) {
    if (response.statusCode >= 500) {
      return 'Não foi possível realizar o cadastro. Tente novamente.';
    }

    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic>) {
        final message = json['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } on FormatException {
      // Uses the default message below when the backend does not return JSON.
    }

    return 'Não foi possível realizar o cadastro.';
  }
}
