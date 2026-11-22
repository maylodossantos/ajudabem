import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'app_item_actions_menu.dart';
import 'app_page_scaffold.dart';
import 'app_svg_icon.dart';

Future<String?> showAppTextInputDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hintText,
  int maxLength = 50,
  String confirmLabel = 'Salvar',
  Key? fieldKey,
  Key? confirmKey,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => AppTextInputDialog(
      title: title,
      initialValue: initialValue,
      hintText: hintText,
      maxLength: maxLength,
      confirmLabel: confirmLabel,
      fieldKey: fieldKey,
      confirmKey: confirmKey,
    ),
  );
}

class AppTextInputDialog extends StatefulWidget {
  const AppTextInputDialog({
    required this.title,
    super.key,
    this.initialValue = '',
    this.hintText,
    this.maxLength = 50,
    this.confirmLabel = 'Salvar',
    this.fieldKey,
    this.confirmKey,
  });

  final String title;
  final String initialValue;
  final String? hintText;
  final int maxLength;
  final String confirmLabel;
  final Key? fieldKey;
  final Key? confirmKey;

  @override
  State<AppTextInputDialog> createState() => _AppTextInputDialogState();
}

class _AppTextInputDialogState extends State<AppTextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue)
    ..addListener(() => setState(() {}));

  bool get _canSave => _controller.text.trim().isNotEmpty;

  void _save() {
    if (_canSave) Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: 2),
    );

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl + AppSpacing.sm),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.manrope(
                        color: AppColors.textStrong,
                        fontSize: AppTextSize.display,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  AppRoundIconButton(
                    asset: AppIcons.close,
                    tooltip: 'Fechar',
                    tint: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                key: widget.fieldKey,
                controller: _controller,
                autofocus: true,
                maxLength: widget.maxLength,
                onSubmitted: (_) => _save(),
                style: GoogleFonts.manrope(
                  color: AppColors.textStrong,
                  fontSize: AppTextSize.title,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: AppColors.surfaceMuted.withValues(alpha: 0.6),
                  focusColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  border: border(Colors.transparent),
                  enabledBorder: border(Colors.transparent),
                  focusedBorder: border(primary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppBottomActions(
                secondaryLabel: 'Cancelar',
                secondaryColor: AppColors.textStrong,
                secondaryBorderColor: AppColors.border,
                onSecondary: () => Navigator.of(context).pop(),
                primaryKey: widget.confirmKey,
                primaryLabel: widget.confirmLabel,
                onPrimary: _canSave ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
