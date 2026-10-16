import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

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

  static final requiredMark = GoogleFonts.manrope(
    color: AppColors.danger,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static BoxDecoration box(BuildContext context) => BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.primary),
    borderRadius: BorderRadius.circular(6),
  );
}

class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(text, style: AppFieldStyles.label)),
        if (required) Text(' *', style: AppFieldStyles.requiredMark),
      ],
    );
  }
}

class AppLabeledField extends StatefulWidget {
  const AppLabeledField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue = '',
    this.hintText = '',
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.required = false,
  });

  final String label;
  final bool required;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String initialValue;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppLabeledField> createState() => _AppLabeledFieldState();
}

class _AppLabeledFieldState extends State<AppLabeledField> {
  late final _controller = TextEditingController(text: widget.initialValue);
  late int _length = widget.initialValue.length;

  @override
  void didUpdateWidget(AppLabeledField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.initialValue;
    if (value != oldWidget.initialValue && value != _controller.text) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
      _length = value.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    if (widget.maxLength != null) setState(() => _length = value.length);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final maxLines = widget.maxLines;
    final maxLength = widget.maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(widget.label, required: widget.required),
        const SizedBox(height: 4),
        Container(
          key: ValueKey('form-field-${widget.label}'),
          height: maxLines == 1 ? 44 : null,
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: maxLines == 1 ? 0 : 10,
          ),
          decoration: AppFieldStyles.box(context),
          child: Center(
            child: TextFormField(
              controller: _controller,
              onChanged: _changed,
              maxLines: maxLines,
              minLines: widget.minLines ?? (maxLines < 3 ? maxLines : 3),
              keyboardType: maxLines == 1
                  ? widget.keyboardType
                  : TextInputType.multiline,
              inputFormatters: [
                ...?widget.inputFormatters,
                if (maxLength != null)
                  LengthLimitingTextInputFormatter(maxLength),
              ],
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
                hintStyle: AppFieldStyles.hint,
              ),
            ),
          ),
        ),
        if (maxLength != null)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$_length/$maxLength',
                style: GoogleFonts.manrope(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 0,
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
    this.required = false,
  });

  final String label;
  final bool required;
  final T? value;
  final List<T> options;
  final ValueChanged<T> onChanged;
  final String Function(T option) labelOf;
  final String? hintText;
  final double height;

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _OptionsSheet<T>(
        title: label.replaceAll(':', '').trim(),
        options: options,
        selected: value,
        labelOf: labelOf,
      ),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label, required: required),
        const SizedBox(height: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('form-dropdown-$label'),
            borderRadius: BorderRadius.circular(6),
            onTap: () => _open(context),
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: AppFieldStyles.box(context),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      current == null ? hintText ?? '' : labelOf(current),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: current == null
                          ? AppFieldStyles.hint
                          : AppFieldStyles.value,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionsSheet<T> extends StatelessWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T option) labelOf;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (_, index) {
                  final option = options[index];
                  final isSelected = option == selected;

                  return Material(
                    color: isSelected
                        ? primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                labelOf(option),
                                style: GoogleFonts.manrope(
                                  color: isSelected
                                      ? primary
                                      : const Color(0xFF232323),
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
