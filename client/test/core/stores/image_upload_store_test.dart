import 'dart:typed_data';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:ajuda_bem/core/stores/image_upload_store.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final file = XFile.fromData(Uint8List(0), name: 'photo.png');

  test('stores the hosted url after a successful upload', () async {
    final store = ImageUploadStore(
      _FakeImageUploadService(url: 'https://i.ibb.co/new/photo.png'),
    );

    final success = await store.upload(file);

    expect(success, isTrue);
    expect(store.imageUrl, 'https://i.ibb.co/new/photo.png');
    expect(store.isUploading, isFalse);
    expect(store.errorMessage, isNull);
  });

  test(
    'keeps the previous photo and exposes the error when upload fails',
    () async {
      final store = ImageUploadStore(
        _FakeImageUploadService(
          error: const AppException('Envio de imagens não está configurado.'),
        ),
      )..setImageUrl('https://i.ibb.co/old/photo.png');

      final success = await store.upload(file);

      expect(success, isFalse);
      expect(store.imageUrl, 'https://i.ibb.co/old/photo.png');
      expect(store.errorMessage, 'Envio de imagens não está configurado.');
      expect(store.isUploading, isFalse);
    },
  );
}

class _FakeImageUploadService implements ImageUploadService {
  _FakeImageUploadService({this.url = '', this.error});

  final String url;
  final Object? error;

  @override
  Future<String> uploadImage(XFile file) async {
    if (error != null) {
      throw error!;
    }
    return url;
  }
}
