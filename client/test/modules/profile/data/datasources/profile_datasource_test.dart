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
            'role': 'USER_ONG',
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
    expect(profile.role, 'USER_ONG');
  });

  test('defaults to a regular user role when absent', () async {
    final datasource = ProfileDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'id': 7,
            'name': 'Maylo Dos Santos',
            'email': 'maylo@email.com',
            'phone': '11999999999',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    final profile = await datasource.getCurrentUser('jwt-token');

    expect(profile.role, 'USER');
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

  test('sends only the provided fields when updating the profile', () async {
    late http.Request capturedRequest;
    final datasource = ProfileDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 7,
            'name': 'New Name',
            'email': 'maylo@email.com',
            'phone': '11999999999',
            'profile_image': 'https://i.ibb.co/abc/photo.png',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final profile = await datasource.updateProfile(
      'jwt-token',
      name: 'New Name',
      profileImage: 'https://i.ibb.co/abc/photo.png',
    );

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/user/me'));
    expect(capturedRequest.method, 'PUT');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    expect(jsonDecode(capturedRequest.body), {
      'name': 'New Name',
      'profileImage': 'https://i.ibb.co/abc/photo.png',
    });
    expect(profile.name, 'New Name');
    expect(profile.profileImage, 'https://i.ibb.co/abc/photo.png');
  });

  test('sends CPF and birth date in the API format', () async {
    late http.Request capturedRequest;
    final datasource = ProfileDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 7,
            'name': 'Maylo',
            'email': 'maylo@email.com',
            'phone': '11999999999',
            'cpf': '52998224725',
            'birth_date': '2000-05-10',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final profile = await datasource.updateProfile(
      'jwt-token',
      cpf: '52998224725',
      birthDate: DateTime(2000, 5, 10),
    );

    expect(jsonDecode(capturedRequest.body), {
      'cpf': '52998224725',
      'birthDate': '2000-05-10',
    });
    expect(profile.cpf, '52998224725');
    expect(profile.birthDate, DateTime(2000, 5, 10));
  });

  test('maps a failed profile update to the validation message', () async {
    final datasource = ProfileDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 400,
            'message': 'Erro de validação',
            'errors': {'name': 'Nome deve ter no máximo 100 caracteres'},
          }),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    expect(
      () => datasource.updateProfile('jwt-token', name: 'x' * 101),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Nome deve ter no máximo 100 caracteres',
        ),
      ),
    );
  });

  test('deletes the account with the bearer token', () async {
    late http.Request capturedRequest;
    final datasource = ProfileDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 200);
      }),
    );

    await datasource.deleteAccount('jwt-token');

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/user/me'));
    expect(capturedRequest.method, 'DELETE');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
  });

  test('maps a failed account deletion to a friendly error', () async {
    final datasource = ProfileDatasourceImpl(
      MockClient((_) async => http.Response('', 500)),
    );

    expect(
      () => datasource.deleteAccount('jwt-token'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Não foi possível excluir sua conta.',
        ),
      ),
    );
  });
}
