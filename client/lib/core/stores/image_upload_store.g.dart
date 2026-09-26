// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ImageUploadStore on ImageUploadStoreBase, Store {
  late final _$imageUrlAtom = Atom(
    name: 'ImageUploadStoreBase.imageUrl',
    context: context,
  );

  @override
  String? get imageUrl {
    _$imageUrlAtom.reportRead();
    return super.imageUrl;
  }

  @override
  set imageUrl(String? value) {
    _$imageUrlAtom.reportWrite(value, super.imageUrl, () {
      super.imageUrl = value;
    });
  }

  late final _$isUploadingAtom = Atom(
    name: 'ImageUploadStoreBase.isUploading',
    context: context,
  );

  @override
  bool get isUploading {
    _$isUploadingAtom.reportRead();
    return super.isUploading;
  }

  @override
  set isUploading(bool value) {
    _$isUploadingAtom.reportWrite(value, super.isUploading, () {
      super.isUploading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'ImageUploadStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$uploadAsyncAction = AsyncAction(
    'ImageUploadStoreBase.upload',
    context: context,
  );

  @override
  Future<bool> upload(XFile file) {
    return _$uploadAsyncAction.run(() => super.upload(file));
  }

  late final _$ImageUploadStoreBaseActionController = ActionController(
    name: 'ImageUploadStoreBase',
    context: context,
  );

  @override
  void setImageUrl(String? url) {
    final _$actionInfo = _$ImageUploadStoreBaseActionController.startAction(
      name: 'ImageUploadStoreBase.setImageUrl',
    );
    try {
      return super.setImageUrl(url);
    } finally {
      _$ImageUploadStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
imageUrl: ${imageUrl},
isUploading: ${isUploading},
errorMessage: ${errorMessage}
    ''';
  }
}
