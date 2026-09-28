import 'dart:typed_data';

class SelectedFile {
  const SelectedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  int get sizeBytes => bytes.length;
}
