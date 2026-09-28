import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppFieldStyles {
  static final label = GoogleFonts.manrope(
    color: const Color(0xFF232323),
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static final value = GoogleFonts.manrope(
    color: const Color(0xFF454545),
    fontSize: 14,
    letterSpacing: 0,
  );

  static final hint = GoogleFonts.manrope(
    color: const Color(0xFFBABABA),
    fontSize: 14,
    letterSpacing: 0,
  );

  static BoxDecoration box(BuildContext context) => BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.primary),
    borderRadius: BorderRadius.circular(6),
  );
}

class AppLabeledField extends StatelessWidget {
  const AppLabeledField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue = '',
    this.hintText = '',
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String initialValue;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFieldStyles.label),
        const SizedBox(height: 4),
        Container(
          key: ValueKey('form-field-$label'),
          height: maxLines == 1 ? 44 : null,
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: maxLines == 1 ? 0 : 10,
          ),
          decoration: AppFieldStyles.box(context),
          child: Center(
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              maxLines: maxLines,
              minLines: maxLines == 1 ? 1 : 3,
              keyboardType: maxLines == 1
                  ? keyboardType
                  : TextInputType.multiline,
              inputFormatters: inputFormatters,
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: AppFieldStyles.hint,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppLabeledDropdown<T> extends StatelessWidget {
  const AppLabeledDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labelOf,
    super.key,
    this.hintText,
    this.height = 44,
  });

  final String label;
  final T? value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(T option) labelOf;
  final String? hintText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFieldStyles.label),
        const SizedBox(height: 4),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: AppFieldStyles.box(context),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hintText == null
                  ? null
                  : Text(hintText!, style: AppFieldStyles.hint),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              style: AppFieldStyles.value,
              items: [
                for (final option in options)
                  DropdownMenuItem(value: option, child: Text(labelOf(option))),
              ],
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
