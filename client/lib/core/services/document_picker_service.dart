import 'package:file_picker/file_picker.dart';

import '../files/selected_file.dart';

abstract interface class DocumentPickerService {
  Future<SelectedFile?> pickPdf();
}

class FilePickerDocumentService implements DocumentPickerService {
  const FilePickerDocumentService();

  @override
  Future<SelectedFile?> pickPdf() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (file == null) {
      return null;
    }

    return SelectedFile(name: file.name, bytes: await file.readAsBytes());
  }
}
