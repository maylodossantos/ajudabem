import 'dart:convert';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/modules/profile/data/datasources/profile_datasource_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('loads the current user with the bearer token', () async {
    late http.Request capturedRequest;
    final datasource = ProfileDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 7,
            'name': 'Maylo Dos Santos',
            'email': 'maylo@email.com',
            'phone': '11999999999',
            'profile_image': null,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final profile = await datasource.getCurrentUser('jwt-token');

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/user/me'));
    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    expect(profile.id, 7);
    expect(profile.name, 'Maylo Dos Santos');
  });

  test('maps an expired session to a friendly error', () async {
    final datasource = ProfileDatasourceImpl(
      MockClient((_) async => http.Response('', 401)),
    );

    expect(
      () => datasource.getCurrentUser('expired-token'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          contains('sessão expirou'),
        ),
      ),
    );
  });
}
