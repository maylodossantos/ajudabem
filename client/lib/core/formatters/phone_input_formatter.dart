import 'package:flutter/services.dart';

import 'masked_input_formatter.dart';

class PhoneInputFormatter extends TextInputFormatter {
  static const _maxDigits = 11;

  static String digitsOnly(String value) =>
      MaskedInputFormatter.digitsOnly(value);

  static String format(String value) {
    final digits = digitsOnly(value);
    final length = digits.length;

    if (length == 0) return '';
    if (length <= 2) return '($digits';

    final area = digits.substring(0, 2);
    final number = digits.substring(2);

    if (number.length <= 4) return '($area) $number';

    final splitAt = length == _maxDigits ? 5 : 4;
    if (number.length <= splitAt) return '($area) $number';

    return '($area) ${number.substring(0, splitAt)}-${number.substring(splitAt)}';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = digitsOnly(newValue.text);
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
    }

    final formatted = format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
