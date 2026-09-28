import 'masked_input_formatter.dart';

class CepInputFormatter extends MaskedInputFormatter {
  CepInputFormatter() : super(_mask);

  static const _mask = '#####-###';

  static String display(String? cep) =>
      cep == null ? '' : MaskedInputFormatter(_mask).format(cep);

  static bool isComplete(String value) =>
      MaskedInputFormatter.digitsOnly(value).length == 8;
}
