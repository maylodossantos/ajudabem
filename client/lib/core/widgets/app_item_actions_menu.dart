import 'package:flutter/material.dart';

enum _ItemAction { edit, delete }

/// Edit/delete overflow menu for a list card; shows a spinner while the item
/// is being deleted so it can't be triggered twice.
class AppItemActionsMenu extends StatelessWidget {
  const AppItemActionsMenu({
    required this.tooltip,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final String tooltip;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return PopupMenuButton<_ItemAction>(
      tooltip: tooltip,
      onSelected: (action) =>
          action == _ItemAction.edit ? onEdit() : onDelete(),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _ItemAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 10),
              Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ItemAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 10),
              Text('Excluir'),
            ],
          ),
        ),
      ],
    );
  }
}
