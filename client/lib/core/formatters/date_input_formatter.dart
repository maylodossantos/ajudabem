import 'masked_input_formatter.dart';

/// Brazilian date mask: 10/05/2000. The API exchanges dates as ISO
/// `yyyy-MM-dd`, see [toIso].
class DateInputFormatter extends MaskedInputFormatter {
  DateInputFormatter() : super('##/##/####');

  /// The typed date, or null while it is incomplete or not a real day
  /// (31/02/2000 would otherwise roll over into March).
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

  /// A birth date is valid when it is a real day before today.
  static DateTime? parseBirthDate(String value) {
    final date = parse(value);
    if (date == null || !date.isBefore(_today())) return null;
    return date;
  }

  static String display(DateTime? date) {
    if (date == null) return '';
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  static String toIso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${_twoDigits(date.month)}-'
      '${_twoDigits(date.day)}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
