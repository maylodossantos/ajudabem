import 'dart:convert';

import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/modules/registration/data/datasources/assisted_person_datasource_impl.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/create_assisted_person_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const params = CreateAssistedPersonParams(
    fullName: 'Maria',
    age: 42,
    gender: 'FEMALE',
    tagIds: [1, 3],
    notes: 'Pessoa precisando de apoio.',
    street: 'Rua das Flores',
    number: '123',
    neighborhood: '',
    city: 'Curitiba',
    state: 'Paraná',
    zipCode: '80000-000',
    country: 'Brasil',
  );

  test('loads registered people using the bearer token', () async {
    late http.Request capturedRequest;
    final datasource = AssistedPersonDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode([
            {'id': 10, 'full_name': 'Maria', 'riskLevel': 'MEDIUM'},
            {'id': 11, 'full_name': 'João', 'riskLevel': 'HIGH'},
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await datasource.getAll('jwt-token');

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/assisted-person'),
    );
    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    expect(result, hasLength(2));
    expect(result.first.fullName, 'Maria');
    expect(result.first.riskLevel, 'MEDIUM');
    expect(result.last.fullName, 'João');
    expect(result.last.riskLevel, 'HIGH');
  });

  test('posts the assisted person using the existing API contract', () async {
    late http.Request capturedRequest;
    final datasource = AssistedPersonDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'id': 10, 'full_name': 'Maria'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await datasource.create(params, 'jwt-token');

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/assisted-person'),
    );
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {
      'full_name': 'Maria',
      'age': 42,
      'gender': 'FEMALE',
      'tagIds': [1, 3],
      'notes': 'Pessoa precisando de apoio.',
      'street': 'Rua das Flores',
      'number': '123',
      'neighborhood': '',
      'city': 'Curitiba',
      'state': 'Paraná',
      'zip_code': '80000-000',
      'country': 'Brasil',
    });
    expect(result.id, 10);
    expect(result.fullName, 'Maria');
  });

  test('updates an assisted person using put', () async {
    late http.Request capturedRequest;
    final datasource = AssistedPersonDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'id': 10, 'full_name': 'Maria'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await datasource.update(10, params, 'jwt-token');

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/assisted-person/10'),
    );
    expect(capturedRequest.method, 'PUT');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    expect(jsonDecode(capturedRequest.body)['zip_code'], '80000-000');
    expect(result.id, 10);
  });

  test('deletes an assisted person using the bearer token', () async {
    late http.Request capturedRequest;
    final datasource = AssistedPersonDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      }),
    );

    await datasource.delete(10, 'jwt-token');

    expect(
      capturedRequest.url,
      Uri.parse('${ApiConfig.baseUrl}/assisted-person/10'),
    );
    expect(capturedRequest.method, 'DELETE');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
  });
}
