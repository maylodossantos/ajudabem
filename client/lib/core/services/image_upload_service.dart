import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../errors/app_exception.dart';
import '../network/imgbb_config.dart';

abstract interface class ImageUploadService {
  Future<String> uploadImage(XFile file);
}

class ImgbbImageUploadService implements ImageUploadService {
  ImgbbImageUploadService(this._client, {String? apiKey})
    : _apiKey = apiKey ?? ImgbbConfig.apiKey;

  final http.Client _client;
  final String _apiKey;

  @override
  Future<String> uploadImage(XFile file) async {
    if (_apiKey.isEmpty) {
      throw const AppException(
        'Envio de imagens não está configurado neste ambiente.',
      );
    }

    try {
      final bytes = await file.readAsBytes();
      final response = await _client.post(
        Uri.parse('${ImgbbConfig.uploadUrl}?key=$_apiKey'),
        body: {'image': base64Encode(bytes)},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const AppException('Não foi possível enviar a imagem.');
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const AppException('Resposta inválida do servidor de imagens.');
      }

      final data = json['data'];
      final url = data is Map<String, dynamic> ? data['url'] : null;

      if (url is! String || url.isEmpty) {
        throw const AppException('Resposta inválida do servidor de imagens.');
      }

      return url;
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException('Resposta inválida do servidor de imagens.');
    } on http.ClientException {
      throw const AppException(
        'Não foi possível conectar ao servidor de imagens.',
      );
    } catch (_) {
      throw const AppException('Não foi possível enviar a imagem.');
    }
  }
}
