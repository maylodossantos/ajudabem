import 'masked_input_formatter.dart';

class TimeInputFormatter extends MaskedInputFormatter {
  TimeInputFormatter() : super('##:##');

  static int? parseMinutes(String value) {
    final digits = MaskedInputFormatter.digitsOnly(value);
    if (digits.length != 4) return null;
    final hours = int.parse(digits.substring(0, 2));
    final minutes = int.parse(digits.substring(2));
    if (hours > 23 || minutes > 59) return null;
    return hours * 60 + minutes;
  }

  static String display(DateTime moment) =>
      '${moment.hour.toString().padLeft(2, '0')}:'
      '${moment.minute.toString().padLeft(2, '0')}';
}
