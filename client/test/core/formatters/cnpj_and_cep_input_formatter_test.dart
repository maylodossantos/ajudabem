import 'package:ajuda_bem/core/formatters/cep_input_formatter.dart';
import 'package:ajuda_bem/core/formatters/cnpj_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String _type(TextInputFormatter formatter, String text) {
  return formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
      .text;
}

void main() {
  test('CNPJ is masked as it is typed and capped at 14 digits', () {
    final formatter = CnpjInputFormatter();

    expect(_type(formatter, '11'), '11');
    expect(_type(formatter, '112'), '11.2');
    expect(_type(formatter, '112223330001'), '11.222.333/0001');
    expect(_type(formatter, '11222333000181999'), '11.222.333/0001-81');
    expect(CnpjInputFormatter.isComplete('11.222.333/0001-8'), isFalse);
    expect(CnpjInputFormatter.isComplete('11.222.333/0001-81'), isTrue);
    expect(CnpjInputFormatter.display('11222333000181'), '11.222.333/0001-81');
  });

  test('CEP is masked as 00000-000', () {
    final formatter = CepInputFormatter();

    expect(_type(formatter, '85800'), '85800');
    expect(_type(formatter, '858000001'), '85800-000');
    expect(CepInputFormatter.isComplete('85800-00'), isFalse);
    expect(CepInputFormatter.display('85800000'), '85800-000');
  });
}
