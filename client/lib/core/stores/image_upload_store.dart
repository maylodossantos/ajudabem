import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

import '../errors/app_exception.dart';
import '../services/image_upload_service.dart';

part 'image_upload_store.g.dart';

class ImageUploadStore = ImageUploadStoreBase with _$ImageUploadStore;

abstract class ImageUploadStoreBase with Store {
  ImageUploadStoreBase(this._service);

  final ImageUploadService _service;

  @observable
  String? imageUrl;

  @observable
  bool isUploading = false;

  @observable
  String? errorMessage;

  @action
  void setImageUrl(String? url) {
    imageUrl = url;
    errorMessage = null;
  }

  @action
  Future<bool> upload(XFile file) async {
    isUploading = true;
    errorMessage = null;

    try {
      imageUrl = await _service.uploadImage(file);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível enviar a imagem.';
      return false;
    } finally {
      isUploading = false;
    }
  }
}
