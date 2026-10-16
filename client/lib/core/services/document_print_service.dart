import 'dart:typed_data';

import 'package:printing/printing.dart';

abstract interface class DocumentPrintService {
  Future<void> printPdf(String fileName, Uint8List bytes);
}

class PrintingDocumentService implements DocumentPrintService {
  const PrintingDocumentService();

  @override
  Future<void> printPdf(String fileName, Uint8List bytes) {
    return Printing.layoutPdf(name: fileName, onLayout: (_) async => bytes);
  }
}
