import 'package:flutter/services.dart';

class MaskedInputFormatter extends TextInputFormatter {
  MaskedInputFormatter(this.mask) : _maxDigits = '#'.allMatches(mask).length;

  final String mask;
  final int _maxDigits;

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  String format(String value) {
    var digits = digitsOnly(value);
    if (digits.length > _maxDigits) {
      digits = digits.substring(0, _maxDigits);
    }

    final buffer = StringBuffer();
    var next = 0;
    for (final char in mask.split('')) {
      if (next == digits.length) break;
      if (char == '#') {
        buffer.write(digits[next++]);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
