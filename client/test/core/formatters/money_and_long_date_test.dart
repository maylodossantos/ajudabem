import 'package:ajuda_bem/core/formatters/date_input_formatter.dart';
import 'package:ajuda_bem/core/formatters/money_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('money is typed in cents and shown in reais', () {
    final formatter = MoneyInputFormatter();
    TextEditingValue type(String text) => formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );

    expect(type('5').text, '0,05');
    expect(type('100050').text, '1.000,50');
    expect(type('').text, '');
    expect(MoneyInputFormatter.parse('1.000,50'), 1000.5);
    expect(MoneyInputFormatter.parse(''), isNull);
    expect(MoneyInputFormatter.display(1234567.8), '1.234.567,80');
  });

  test('long dates are written in Portuguese', () {
    expect(
      DateInputFormatter.longDate(DateTime(2026, 3, 21)),
      'Sábado, 21 de março',
    );
    expect(
      DateInputFormatter.dayAndMonth(DateTime(2025, 11, 23)),
      '23 de novembro',
    );
  });
}
