import 'masked_input_formatter.dart';

class CnpjInputFormatter extends MaskedInputFormatter {
  CnpjInputFormatter() : super(_mask);

  static const _mask = '##.###.###/####-##';

  static String display(String? cnpj) =>
      cnpj == null ? '' : MaskedInputFormatter(_mask).format(cnpj);

  static bool isComplete(String value) =>
      MaskedInputFormatter.digitsOnly(value).length == 14;
}
