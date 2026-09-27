import 'dart:convert';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/modules/auth/data/datasources/auth_datasource_impl.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/register_user_params.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/sign_in_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final params = RegisterUserParams(
    name: 'Bruno',
    email: 'bruno@email.com',
    phone: '11999999999',
    cpf: '52998224725',
    birthDate: DateTime(2000, 5, 10),
    password: '123456',
    acceptedTerms: true,
  );
  const signInParams = SignInParams(
    email: 'bruno@email.com',
    password: '123456',
  );

  test('posts credentials and maps the authenticated session', () async {
    late http.Request capturedRequest;
    final datasource = AuthDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'name': 'Bruno', 'token': 'jwt-token'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final session = await datasource.signIn(signInParams);

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/auth/login'));
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {
      'email': 'bruno@email.com',
      'password': '123456',
    });
    expect(session.name, 'Bruno');
    expect(session.token, 'jwt-token');
  });

  for (final (status, message) in [
    (404, 'E-mail não cadastrado.'),
    (401, 'Senha incorreta.'),
  ]) {
    test('tells the user why login failed on a $status', () {
      final datasource = AuthDatasourceImpl(
        MockClient(
          (_) async => http.Response('{"message": "raw backend text"}', status),
        ),
      );

      expect(
        () => datasource.signIn(signInParams),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            message,
          ),
        ),
      );
    });
  }

  test('maps an empty login response to invalid credentials', () async {
    final datasource = AuthDatasourceImpl(
      MockClient((_) async => http.Response('null', 200)),
    );

    expect(
      () => datasource.signIn(signInParams),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'E-mail ou senha inválidos.',
        ),
      ),
    );
  });

  test('posts the registration payload and maps the session', () async {
    late http.Request capturedRequest;
    final datasource = AuthDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'name': 'Bruno', 'token': 'jwt-token'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final session = await datasource.register(params);

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
    );
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {
      'name': 'Bruno',
      'email': 'bruno@email.com',
      'phone': '11999999999',
      'cpf': '52998224725',
      'birthDate': '2000-05-10',
      'password': '123456',
      'acceptedTerms': true,
    });
    expect(session.name, 'Bruno');
    expect(session.token, 'jwt-token');
  });

  for (final (backend, shown) in [
    ('Email is using', 'E-mail já cadastrado.'),
    ('CPF is using', 'CPF já cadastrado em outra conta.'),
  ]) {
    test('shows "$shown" when the backend answers "$backend"', () async {
      final datasource = AuthDatasourceImpl(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'message': backend, 'status': 409}),
            409,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );

      expect(
        () => datasource.register(params),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            shown,
          ),
        ),
      );
    });
  }

  test('shows the first field error of a validation failure', () async {
    final datasource = AuthDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 400,
            'message': 'Erro de validação',
            'errors': {'cpf': 'CPF inválido'},
          }),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    expect(
      () => datasource.register(params),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'CPF inválido',
        ),
      ),
    );
  });

  test('throws a friendly error when the API is unavailable', () async {
    final datasource = AuthDatasourceImpl(
      MockClient((_) async => throw http.ClientException('offline')),
    );

    expect(
      () => datasource.register(params),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          contains('Verifique se a API está ativa'),
        ),
      ),
    );
  });

  test('posts the email to forgot-password', () async {
    late http.Request capturedRequest;
    final datasource = AuthDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 200);
      }),
    );

    await datasource.forgotPassword('bruno@email.com');

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
    );
    expect(jsonDecode(capturedRequest.body), {'email': 'bruno@email.com'});
  });

  test('surfaces the backend message when forgot-password fails', () async {
    final datasource = AuthDatasourceImpl(
      MockClient(
        (_) async =>
            http.Response(jsonEncode({'message': 'User not found'}), 404),
      ),
    );

    expect(
      () => datasource.forgotPassword('missing@email.com'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'User not found',
        ),
      ),
    );
  });

  test('posts the email and code, returning the reset token', () async {
    late http.Request capturedRequest;
    final datasource = AuthDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode({'resetToken': 'the-token'}), 200);
      }),
    );

    final resetToken = await datasource.verifyCode('bruno@email.com', '1234');

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-code'),
    );
    expect(jsonDecode(capturedRequest.body), {
      'email': 'bruno@email.com',
      'code': '1234',
    });
    expect(resetToken, 'the-token');
  });

  test('throws when the verification code is invalid', () async {
    final datasource = AuthDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Invalid or expired verification code'}),
          401,
        ),
      ),
    );

    expect(
      () => datasource.verifyCode('bruno@email.com', '9999'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Invalid or expired verification code',
        ),
      ),
    );
  });

  test('posts the reset token and new password', () async {
    late http.Request capturedRequest;
    final datasource = AuthDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 200);
      }),
    );

    await datasource.resetPassword(
      email: 'bruno@email.com',
      resetToken: 'the-token',
      password: 'newPassword123',
      confirmPassword: 'newPassword123',
    );

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
    );
    expect(jsonDecode(capturedRequest.body), {
      'email': 'bruno@email.com',
      'resetToken': 'the-token',
      'password': 'newPassword123',
      'confirmPassword': 'newPassword123',
    });
  });

  test('throws when resetting the password fails', () async {
    final datasource = AuthDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Passwords do not match'}),
          400,
        ),
      ),
    );

    expect(
      () => datasource.resetPassword(
        email: 'bruno@email.com',
        resetToken: 'the-token',
        password: 'newPassword123',
        confirmPassword: 'somethingElse',
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Passwords do not match',
        ),
      ),
    );
  });
}
