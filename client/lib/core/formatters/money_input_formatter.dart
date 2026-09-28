import 'package:flutter/services.dart';

import 'masked_input_formatter.dart';

class MoneyInputFormatter extends TextInputFormatter {
  static const _maxDigits = 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = MaskedInputFormatter.digitsOnly(newValue.text);
    if (digits.isEmpty) return const TextEditingValue();
    final cents = int.parse(
      digits.length > _maxDigits ? digits.substring(0, _maxDigits) : digits,
    );
    final text = display(cents / 100);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static String display(double value) {
    final cents = (value * 100).round();
    final whole = (cents ~/ 100).toString();
    final grouped = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '$grouped,${(cents % 100).toString().padLeft(2, '0')}';
  }

  static double? parse(String value) {
    final digits = MaskedInputFormatter.digitsOnly(value);
    return digits.isEmpty ? null : int.parse(digits) / 100;
  }
}
