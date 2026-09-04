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
  const params = RegisterUserParams(
    name: 'Bruno',
    email: 'bruno@email.com',
    phone: '11999999999',
    password: '123456',
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
      'password': '123456',
    });
    expect(session.name, 'Bruno');
    expect(session.token, 'jwt-token');
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
}
