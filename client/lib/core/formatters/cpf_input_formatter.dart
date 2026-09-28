import 'masked_input_formatter.dart';

class CpfInputFormatter extends MaskedInputFormatter {
  CpfInputFormatter() : super(_mask);

  static const _mask = '###.###.###-##';

  static String display(String? cpf) =>
      cpf == null ? '' : MaskedInputFormatter(_mask).format(cpf);

  static bool isComplete(String value) =>
      MaskedInputFormatter.digitsOnly(value).length == 11;
}
