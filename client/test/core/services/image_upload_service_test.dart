import 'dart:convert';
import 'dart:typed_data';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/network/imgbb_config.dart';
import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ImgbbImageUploadService', () {
    test('throws when no imgbb API key is configured', () async {
      final service = ImgbbImageUploadService(
        MockClient((_) async => http.Response('', 200)),
        apiKey: '',
      );
      final file = XFile.fromData(Uint8List(0), name: 'photo.png');

      expect(() => service.uploadImage(file), throwsA(isA<AppException>()));
    });

    test('posts the base64 image and returns the hosted url', () async {
      late http.Request capturedRequest;
      final service = ImgbbImageUploadService(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'data': {'url': 'https://i.ibb.co/abc/photo.png'},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
        apiKey: 'test-key',
      );
      final bytes = Uint8List.fromList([1, 2, 3]);
      final file = XFile.fromData(bytes, name: 'photo.png');

      final url = await service.uploadImage(file);

      expect(url, 'https://i.ibb.co/abc/photo.png');
      expect(capturedRequest.method, 'POST');
      expect(
        capturedRequest.url,
        Uri.parse('${ImgbbConfig.uploadUrl}?key=test-key'),
      );
      expect(capturedRequest.bodyFields['image'], base64Encode(bytes));
    });

    test('maps a failed upload to a friendly error', () async {
      final service = ImgbbImageUploadService(
        MockClient((_) async => http.Response('', 400)),
        apiKey: 'test-key',
      );
      final file = XFile.fromData(Uint8List(0), name: 'photo.png');

      expect(() => service.uploadImage(file), throwsA(isA<AppException>()));
    });

    test('maps an unexpected response shape to a friendly error', () async {
      final service = ImgbbImageUploadService(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'data': {}}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
        apiKey: 'test-key',
      );
      final file = XFile.fromData(Uint8List(0), name: 'photo.png');

      expect(() => service.uploadImage(file), throwsA(isA<AppException>()));
    });
  });
}
