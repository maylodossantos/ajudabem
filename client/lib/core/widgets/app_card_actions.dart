import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

const _cardButtonHeight = 40.0;
const _cardButtonPadding = AppSpacing.sm;
const _cardButtonGap = AppSpacing.md;

RoundedRectangleBorder _cardButtonShape() =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));

class AppCardButton extends StatelessWidget {
  const AppCardButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.leading,
    this.fontSize = AppTextSize.title,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: _cardButtonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surfaceMuted,
          padding: const EdgeInsets.symmetric(horizontal: _cardButtonPadding),
          shape: _cardButtonShape(),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading case final leading?) ...[
                leading,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: AppButtonLabel.style(primary, fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCardActions extends StatelessWidget {
  const AppCardActions({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    super.key,
    this.primaryKey,
    this.primaryDone = false,
    this.isLoading = false,
    this.secondaryLeading,
  });

  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final Key? primaryKey;
  final bool primaryDone;
  final bool isLoading;
  final Widget? secondaryLeading;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final done = primary.withValues(alpha: 0.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth =
            (constraints.maxWidth - _cardButtonGap) / 2 -
            2 * _cardButtonPadding -
            (secondaryLeading == null ? 4 : 28);
        final fontSize = AppButtonLabel.fitSize([
          secondaryLabel,
          primaryLabel,
        ], labelWidth);

        return Row(
          children: [
            Expanded(
              child: AppCardButton(
                label: secondaryLabel,
                onPressed: onSecondary,
                leading: secondaryLeading,
                fontSize: fontSize,
              ),
            ),
            const SizedBox(width: _cardButtonGap),
            Expanded(
              child: SizedBox(
                height: _cardButtonHeight,
                child: FilledButton(
                  key: primaryKey,
                  onPressed: primaryDone || isLoading ? null : onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: primaryDone ? done : primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: _cardButtonPadding,
                    ),
                    shape: _cardButtonShape(),
                  ),
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            primaryLabel,
                            maxLines: 1,
                            softWrap: false,
                            style: AppButtonLabel.style(Colors.white, fontSize),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
