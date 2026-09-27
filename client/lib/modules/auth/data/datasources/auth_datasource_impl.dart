import 'package:http/http.dart' as http;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/network/api_requester.dart';
import '../../../../core/network/server_messages.dart';
import '../../domain/entities/register_user_params.dart';
import '../../domain/entities/sign_in_params.dart';
import '../models/auth_session_model.dart';
import 'auth_datasource.dart';

class AuthDatasourceImpl implements AuthDatasource {
  AuthDatasourceImpl(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  @override
  Future<AuthSessionModel> signIn(SignInParams params) {
    return _api.request(
      HttpMethod.post,
      '/auth/login',
      body: {'email': params.email, 'password': params.password},
      errorMessage: 'Não foi possível entrar. Confira seu e-mail e sua senha.',
      useServerMessage: false,
      statusMessages: const {
        404: 'E-mail não cadastrado.',
        401: 'Senha incorreta.',
      },
      onSuccess: (response) {
        const invalidCredentials = 'E-mail ou senha inválidos.';
        final session = AuthSessionModel.fromJson(
          ApiRequester.decodeObject(
            response,
            invalidMessage: invalidCredentials,
          ),
        );
        if (session.token.isEmpty) {
          throw const AppException(invalidCredentials);
        }
        return session;
      },
    );
  }

  @override
  Future<AuthSessionModel> register(RegisterUserParams params) {
    return _api.request(
      HttpMethod.post,
      '/auth/register',
      body: {
        'name': params.name,
        'email': params.email,
        'phone': params.phone,
        'cpf': params.cpf,
        'birthDate': DateInputFormatter.toIso(params.birthDate),
        'password': params.password,
        'acceptedTerms': params.acceptedTerms,
      },
      errorMessage: 'Não foi possível realizar o cadastro.',
      serverMessages: ServerMessages.userConflicts,
      onSuccess: (response) {
        final session = AuthSessionModel.fromJson(
          ApiRequester.decodeObject(response),
        );
        if (session.token.isEmpty) {
          throw const AppException(
            'O servidor não retornou um token de acesso.',
          );
        }
        return session;
      },
    );
  }

  @override
  Future<void> forgotPassword(String email) {
    return _api.request(
      HttpMethod.post,
      '/auth/forgot-password',
      body: {'email': email},
      errorMessage: 'Não foi possível enviar o código.',
      onSuccess: (_) {},
    );
  }

  @override
  Future<String> verifyCode(String email, String code) {
    return _api.request(
      HttpMethod.post,
      '/auth/verify-code',
      body: {'email': email, 'code': code},
      errorMessage: 'Código inválido ou expirado.',
      onSuccess: (response) {
        final resetToken = ApiRequester.decodeObject(response)['resetToken'];
        if (resetToken is! String) {
          throw const AppException(ApiRequester.invalidResponseMessage);
        }
        return resetToken;
      },
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) {
    return _api.request(
      HttpMethod.post,
      '/auth/reset-password',
      body: {
        'email': email,
        'resetToken': resetToken,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      errorMessage: 'Não foi possível redefinir a senha.',
      onSuccess: (_) {},
    );
  }
}
