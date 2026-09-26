import 'masked_input_formatter.dart';

/// CPF mask: 529.982.247-25. The backend stores digits only and checks the
/// verification digits, so the app only makes sure all 11 were typed.
class CpfInputFormatter extends MaskedInputFormatter {
  CpfInputFormatter() : super(_mask);

  static const _mask = '###.###.###-##';

  static String display(String? cpf) =>
      cpf == null ? '' : MaskedInputFormatter(_mask).format(cpf);

  static bool isComplete(String value) =>
      MaskedInputFormatter.digitsOnly(value).length == 11;
}
