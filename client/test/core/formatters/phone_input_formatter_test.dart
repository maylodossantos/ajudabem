import 'package:ajuda_bem/core/formatters/phone_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneInputFormatter.format', () {
    test('formats an 11-digit mobile number', () {
      expect(PhoneInputFormatter.format('45998029132'), '(45) 99802-9132');
    });

    test('formats a 10-digit landline number', () {
      expect(PhoneInputFormatter.format('4532221234'), '(45) 3222-1234');
    });

    test('reformats an already formatted value', () {
      expect(PhoneInputFormatter.format('(45) 99802-9132'), '(45) 99802-9132');
    });

    test('formats partial input while typing', () {
      expect(PhoneInputFormatter.format(''), '');
      expect(PhoneInputFormatter.format('4'), '(4');
      expect(PhoneInputFormatter.format('459'), '(45) 9');
      expect(PhoneInputFormatter.format('4599802'), '(45) 9980-2');
    });
  });

  test('digitsOnly strips the mask', () {
    expect(PhoneInputFormatter.digitsOnly('(45) 99802-9132'), '45998029132');
  });

  test('caps input at 11 digits', () {
    final result = PhoneInputFormatter().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '459980291329999'),
    );

    expect(result.text, '(45) 99802-9132');
  });
}
