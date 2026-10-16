import 'dart:convert';

import 'package:ajuda_bem/core/services/cep_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  test('maps the ViaCEP address and caches the result', () async {
    var calls = 0;
    final service = HttpCepService(
      MockClient((request) async {
        calls++;
        expect(request.url.host, 'viacep.com.br');
        expect(request.url.path, '/ws/85801000/json/');
        return json({
          'logradouro': 'Avenida Brasil',
          'bairro': 'Centro',
          'localidade': 'Cascavel',
          'uf': 'PR',
        });
      }),
    );

    final address = await service.lookup('85801-000');
    await service.lookup('85801000');

    expect(address?.street, 'Avenida Brasil');
    expect(address?.neighborhood, 'Centro');
    expect(address?.city, 'Cascavel');
    expect(address?.state, 'PR');
    expect(calls, 1);
  });

  test('falls back to BrasilAPI when ViaCEP fails', () async {
    final service = HttpCepService(
      MockClient((request) async {
        if (request.url.host == 'viacep.com.br') return http.Response('', 500);
        return json({
          'street': 'Rua Paraná',
          'neighborhood': 'Centro',
          'city': 'Cascavel',
          'state': 'PR',
        });
      }),
    );

    final address = await service.lookup('85801000');

    expect(address?.street, 'Rua Paraná');
  });

  test('returns null for unknown or incomplete CEPs', () async {
    final service = HttpCepService(
      MockClient((request) async {
        if (request.url.host == 'viacep.com.br') return json({'erro': true});
        return json({'message': 'not found'}, 404);
      }),
    );

    expect(await service.lookup('00000000'), isNull);
    expect(await service.lookup('123'), isNull);
  });
}
