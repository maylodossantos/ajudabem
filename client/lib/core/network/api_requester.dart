import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import 'api_config.dart';

enum HttpMethod { get, post, put, delete }

/// Single place that turns an API call into either a parsed result or an
/// [AppException] with a user-facing message, so datasources only describe
/// the endpoint and how to read its body.
class ApiRequester {
  const ApiRequester(this._client);

  final http.Client _client;

  static const connectionErrorMessage =
      'Não foi possível conectar ao servidor. Verifique se a API está ativa.';
  static const sessionExpiredMessage =
      'Sua sessão expirou. Entre novamente para continuar.';
  static const invalidResponseMessage =
      'Resposta inválida recebida do servidor.';

  /// [errorMessage] is shown for any failure without a better message.
  /// [statusMessages] gives specific statuses their own message; otherwise,
  /// with [useServerMessage], a 4xx `message` from the backend wins: the
  /// first Portuguese field error of a validation failure, or the backend's
  /// (English) message looked up in [serverMessages] to show it translated.
  /// Statuses in [sessionExpiredStatuses] mean the token is no longer valid.
  Future<T> request<T>(
    HttpMethod method,
    String path, {
    required String errorMessage,
    required T Function(http.Response response) onSuccess,
    String? token,
    Object? body,
    bool useServerMessage = true,
    Map<int, String> statusMessages = const {},
    Map<String, String> serverMessages = const {},
    Set<int> sessionExpiredStatuses = const {},
  }) async {
    try {
      final response = await _send(method, path, token: token, body: body);

      if (sessionExpiredStatuses.contains(response.statusCode)) {
        throw const AppException(sessionExpiredMessage);
      }

      final statusMessage = statusMessages[response.statusCode];
      if (statusMessage != null) {
        throw AppException(statusMessage);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverMessage = useServerMessage
            ? _serverMessage(response)
            : null;
        throw AppException(
          serverMessages[serverMessage] ?? serverMessage ?? errorMessage,
        );
      }

      return onSuccess(response);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException(invalidResponseMessage);
    } on http.ClientException {
      throw const AppException(connectionErrorMessage);
    } catch (_) {
      throw AppException(errorMessage);
    }
  }

  static Map<String, dynamic> decodeObject(
    http.Response response, {
    String invalidMessage = invalidResponseMessage,
  }) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic>) {
        return json;
      }
    } on FormatException {
      // Falls through to the invalid-response error below.
    }

    throw AppException(invalidMessage);
  }

  static List<Map<String, dynamic>> decodeList(http.Response response) {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! List<dynamic>) {
      throw const AppException(invalidResponseMessage);
    }

    return json.whereType<Map<String, dynamic>>().toList();
  }

  Future<http.Response> _send(
    HttpMethod method,
    String path, {
    String? token,
    Object? body,
  }) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {
      if (body != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final encodedBody = body == null ? null : jsonEncode(body);

    return switch (method) {
      HttpMethod.get => _client.get(uri, headers: headers),
      HttpMethod.post => _client.post(uri, headers: headers, body: encodedBody),
      HttpMethod.put => _client.put(uri, headers: headers, body: encodedBody),
      HttpMethod.delete => _client.delete(uri, headers: headers),
    };
  }

  String? _serverMessage(http.Response response) {
    if (response.statusCode >= 500) {
      return null;
    }

    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic>) {
        final fieldErrors = json['errors'];
        if (fieldErrors is Map<String, dynamic>) {
          final first = fieldErrors.values.whereType<String>().firstOrNull;
          if (first != null && first.isNotEmpty) {
            return first;
          }
        }

        final message = json['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } on FormatException {
      // Non-JSON error bodies fall back to the caller's message.
    }

    return null;
  }
}
