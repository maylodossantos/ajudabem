import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_svg_icon.dart';

class AppItemActionsMenu extends StatelessWidget {
  const AppItemActionsMenu({
    required this.itemLabel,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final String itemLabel;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: SizedBox.square(
          dimension: AppRoundIconButton.iconSize,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        AppRoundIconButton(
          asset: AppIcons.edit,
          tooltip: 'Editar $itemLabel',
          tint: Theme.of(context).colorScheme.primary,
          onPressed: onEdit,
        ),
        AppRoundIconButton(
          asset: AppIcons.delete,
          tooltip: 'Excluir $itemLabel',
          tint: AppColors.danger,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class AppRoundIconButton extends StatelessWidget {
  const AppRoundIconButton({
    required this.asset,
    required this.tooltip,
    required this.tint,
    required this.onPressed,
    super.key,
  });

  static const size = 36.0;
  static const iconSize = 18.0;

  final String asset;
  final String tooltip;
  final Color tint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: size, height: size),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        hoverColor: tint.withValues(alpha: 0.1),
        highlightColor: tint.withValues(alpha: 0.16),
      ),
      icon: AppSvgIcon(asset, size: iconSize),
    );
  }
}
