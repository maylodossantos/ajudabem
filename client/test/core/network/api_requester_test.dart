import 'dart:convert';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/core/network/api_requester.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Matcher throwsMessage(Object matcher) => throwsA(
    isA<AppException>().having((error) => error.message, 'message', matcher),
  );

  ApiRequester requesterReturning(http.Response response) =>
      ApiRequester(MockClient((_) async => response));

  Future<void> call(ApiRequester api, {bool useServerMessage = true}) {
    return api.request(
      HttpMethod.get,
      '/thing',
      errorMessage: 'Falhou.',
      useServerMessage: useServerMessage,
      sessionExpiredStatuses: const {401},
      onSuccess: (_) {},
    );
  }

  test('sends JSON body and bearer token to the configured base URL', () async {
    late http.Request captured;
    final api = ApiRequester(
      MockClient((request) async {
        captured = request;
        return http.Response('{"ok": true}', 200);
      }),
    );

    final result = await api.request(
      HttpMethod.post,
      '/thing',
      token: 'jwt',
      body: {'a': 1},
      errorMessage: 'Falhou.',
      onSuccess: ApiRequester.decodeObject,
    );

    expect(captured.url, Uri.parse('${ApiConfig.baseUrl}/thing'));
    expect(captured.headers['Authorization'], 'Bearer jwt');
    expect(jsonDecode(captured.body), {'a': 1});
    expect(result, {'ok': true});
  });

  test('prefers the backend message on a 4xx', () {
    final api = requesterReturning(
      http.Response(jsonEncode({'message': 'Email is using'}), 409),
    );

    expect(call(api), throwsMessage('Email is using'));
  });

  test('ignores the backend message when asked to', () {
    final api = requesterReturning(
      http.Response(jsonEncode({'message': 'raw'}), 400),
    );

    expect(call(api, useServerMessage: false), throwsMessage('Falhou.'));
  });

  test('falls back to the caller message on a 5xx', () {
    final api = requesterReturning(
      http.Response(jsonEncode({'message': 'NullPointerException'}), 500),
    );

    expect(call(api), throwsMessage('Falhou.'));
  });

  test('maps configured statuses to an expired session', () {
    final api = requesterReturning(http.Response('', 401));

    expect(call(api), throwsMessage(ApiRequester.sessionExpiredMessage));
  });

  test('maps a network failure to the connection message', () {
    final api = ApiRequester(
      MockClient((_) async => throw http.ClientException('offline')),
    );

    expect(call(api), throwsMessage(ApiRequester.connectionErrorMessage));
  });

  test('maps an unparseable success body to the invalid response message', () {
    final api = requesterReturning(http.Response('not json', 200));

    expect(
      api.request(
        HttpMethod.get,
        '/thing',
        errorMessage: 'Falhou.',
        onSuccess: ApiRequester.decodeObject,
      ),
      throwsMessage(ApiRequester.invalidResponseMessage),
    );
  });
}
