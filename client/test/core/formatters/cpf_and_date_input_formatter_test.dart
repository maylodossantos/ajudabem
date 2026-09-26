import 'package:ajuda_bem/core/formatters/cpf_input_formatter.dart';
import 'package:ajuda_bem/core/formatters/date_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String _type(TextInputFormatter formatter, String text) {
  return formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
      .text;
}

void main() {
  group('CpfInputFormatter', () {
    test('masks the digits as they are typed', () {
      final formatter = CpfInputFormatter();

      expect(_type(formatter, '529'), '529');
      expect(_type(formatter, '5299'), '529.9');
      expect(_type(formatter, '529982247'), '529.982.247');
      expect(_type(formatter, '5299822472'), '529.982.247-2');
      expect(_type(formatter, '52998224725'), '529.982.247-25');
    });

    test('drops extra digits and anything that is not a digit', () {
      expect(_type(CpfInputFormatter(), 'a52998224725999'), '529.982.247-25');
    });

    test('isComplete only once all 11 digits are there', () {
      expect(CpfInputFormatter.isComplete('529.982.247-2'), isFalse);
      expect(CpfInputFormatter.isComplete('529.982.247-25'), isTrue);
    });

    test('display masks a stored CPF and tolerates null', () {
      expect(CpfInputFormatter.display('52998224725'), '529.982.247-25');
      expect(CpfInputFormatter.display(null), '');
    });
  });

  group('DateInputFormatter', () {
    test('masks the digits as dd/mm/aaaa', () {
      final formatter = DateInputFormatter();

      expect(_type(formatter, '10'), '10');
      expect(_type(formatter, '100'), '10/0');
      expect(_type(formatter, '10052000'), '10/05/2000');
    });

    test('parse rejects incomplete and impossible dates', () {
      expect(DateInputFormatter.parse('10/05/2000'), DateTime(2000, 5, 10));
      expect(DateInputFormatter.parse('10/05/20'), isNull);
      expect(DateInputFormatter.parse('31/02/2000'), isNull);
      expect(DateInputFormatter.parse('10/13/2000'), isNull);
    });

    test('parseBirthDate rejects today and future dates', () {
      final now = DateTime.now();
      final today = DateInputFormatter.display(now);
      final nextYear = DateInputFormatter.display(
        DateTime(now.year + 1, now.month, 1),
      );

      expect(DateInputFormatter.parseBirthDate(today), isNull);
      expect(DateInputFormatter.parseBirthDate(nextYear), isNull);
      expect(
        DateInputFormatter.parseBirthDate('10/05/2000'),
        DateTime(2000, 5, 10),
      );
    });

    test('converts between display and the API ISO format', () {
      expect(DateInputFormatter.display(DateTime(2000, 5, 1)), '01/05/2000');
      expect(DateInputFormatter.display(null), '');
      expect(DateInputFormatter.toIso(DateTime(2000, 5, 1)), '2000-05-01');
    });
  });
}
