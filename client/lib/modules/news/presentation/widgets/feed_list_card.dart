import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/app_item_actions_menu.dart';
import '../../../../core/widgets/app_list_card.dart';
import 'feed_item.dart';

class FeedListCard extends StatelessWidget {
  const FeedListCard({
    required this.item,
    required this.onTap,
    super.key,
    this.menuItemLabel = 'item',
    this.isDeleting = false,
    this.onEdit,
    this.onDelete,
  });

  final FeedItem item;
  final VoidCallback onTap;
  final String menuItemLabel;
  final bool isDeleting;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const _thumbSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final onEdit = this.onEdit;
    final onDelete = this.onDelete;

    return AppListCard(
      onTap: onTap,
      leading: SizedBox.square(
        dimension: _thumbSize,
        child: AppCoverImage(
          imageUrl: item.coverImage,
          aspectRatio: 1,
          borderRadius: BorderRadius.circular(AppRadius.md),
          placeholder: ColoredBox(
            color: AppColors.border,
            child: Icon(item.placeholderIcon, color: Colors.white),
          ),
        ),
      ),
      title: item.title,
      subtitle: item.meta,
      trailing: onEdit != null && onDelete != null
          ? AppItemActionsMenu(
              itemLabel: menuItemLabel,
              isBusy: isDeleting,
              onEdit: onEdit,
              onDelete: onDelete,
            )
          : null,
    );
  }
}
