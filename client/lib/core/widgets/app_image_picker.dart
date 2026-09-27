import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../stores/image_upload_store.dart';
import 'app_feedback.dart';

/// Opens the gallery and uploads the picked photo through [store].
/// Cancelling the picker does nothing; a failed upload shows its error.
Future<void> pickAndUploadGalleryImage(
  BuildContext context,
  ImageUploadStore store,
) async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (file == null) {
    return;
  }

  final success = await store.upload(file);
  if (success || !context.mounted) {
    return;
  }

  showAppSnackBar(
    context,
    store.errorMessage ?? 'Não foi possível enviar a imagem.',
  );
}
