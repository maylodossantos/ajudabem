import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

abstract interface class FileDownloadService {
  Future<void> savePdf(String fileName, Uint8List bytes);
}

class FileSaverDownloadService implements FileDownloadService {
  const FileSaverDownloadService();

  @override
  Future<void> savePdf(String fileName, Uint8List bytes) {
    final name = fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;

    return FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }
}
