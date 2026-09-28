import 'masked_input_formatter.dart';

class DateInputFormatter extends MaskedInputFormatter {
  DateInputFormatter() : super('##/##/####');

  static DateTime? parse(String value) {
    final digits = MaskedInputFormatter.digitsOnly(value);
    if (digits.length != 8) return null;

    final day = int.parse(digits.substring(0, 2));
    final month = int.parse(digits.substring(2, 4));
    final year = int.parse(digits.substring(4));
    final date = DateTime(year, month, day);

    final isRealDay =
        date.year == year && date.month == month && date.day == day;
    return isRealDay ? date : null;
  }

  static DateTime? parseBirthDate(String value) {
    final date = parse(value);
    if (date == null || !date.isBefore(_today())) return null;
    return date;
  }

  static String display(DateTime? date) {
    if (date == null) return '';
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  static String displayWithTime(DateTime date) =>
      '${display(date)} às ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  static String toIso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${_twoDigits(date.month)}-'
      '${_twoDigits(date.day)}';

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static const _weekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  static String dayAndMonth(DateTime date) =>
      '${date.day} de ${_months[date.month - 1]}';

  static String longDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${dayAndMonth(date)}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
