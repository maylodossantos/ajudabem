import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../errors/app_exception.dart';
import 'api_config.dart';

enum HttpMethod { get, post, put, delete }

class ApiFile {
  const ApiFile({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String fileName;
  final Uint8List bytes;
  final String contentType;
}

class ApiRequester {
  const ApiRequester(this._client);

  final http.Client _client;

  static const connectionErrorMessage =
      'Não foi possível conectar ao servidor. Verifique se a API está ativa.';
  static const sessionExpiredMessage =
      'Sua sessão expirou. Entre novamente para continuar.';
  static const invalidResponseMessage =
      'Resposta inválida recebida do servidor.';

  Future<T> request<T>(
    HttpMethod method,
    String path, {
    required String errorMessage,
    required T Function(http.Response response) onSuccess,
    String? token,
    Object? body,
    Map<String, ApiFile>? files,
    bool useServerMessage = true,
    Map<int, String> statusMessages = const {},
    Map<String, String> serverMessages = const {},
    Set<int> sessionExpiredStatuses = const {},
    Map<int, T Function()> statusResults = const {},
  }) async {
    try {
      final response = files == null
          ? await _send(method, path, token: token, body: body)
          : await _sendMultipart(method, path, token, body, files);

      if (sessionExpiredStatuses.contains(response.statusCode)) {
        throw const AppException(sessionExpiredMessage);
      }

      final statusResult = statusResults[response.statusCode];
      if (statusResult != null) {
        return statusResult();
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
    final json = _tryDecode(response);
    if (json is Map<String, dynamic>) {
      return json;
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

  Future<http.Response> _sendMultipart(
    HttpMethod method,
    String path,
    String? token,
    Object? body,
    Map<String, ApiFile> files,
  ) async {
    final request = http.MultipartRequest(
      method.name.toUpperCase(),
      Uri.parse('${ApiConfig.baseUrl}$path'),
    )..headers.addAll({if (token != null) 'Authorization': 'Bearer $token'});

    if (body != null) {
      request.files.add(
        http.MultipartFile.fromString(
          'data',
          jsonEncode(body),
          contentType: MediaType('application', 'json'),
        ),
      );
    }
    for (final MapEntry(key: part, value: file) in files.entries) {
      request.files.add(
        http.MultipartFile.fromBytes(
          part,
          file.bytes,
          filename: file.fileName,
          contentType: MediaType.parse(file.contentType),
        ),
      );
    }

    return http.Response.fromStream(await _client.send(request));
  }

  static Object? _tryDecode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  String? _serverMessage(http.Response response) {
    final json = response.statusCode >= 500 ? null : _tryDecode(response);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final errors = json['errors'];
    final fieldError = errors is Map<String, dynamic>
        ? errors.values.whereType<String>().firstOrNull
        : null;
    final message = json['message'];
    if (fieldError != null && fieldError.isNotEmpty) return fieldError;
    return message is String && message.isNotEmpty ? message : null;
  }
}
