import 'package:flutter/material.dart';

import 'ajuda_bem_logo.dart';
import 'app_notification_bell.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({
    super.key,
    this.showBackButton = false,
    this.showSearchButton = false,
    this.onBack,
    this.onSearch,
  });

  final bool showBackButton;
  final bool showSearchButton;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: const AjudaBemLogo(),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: AppNotificationBell(),
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        onPressed: onBack ?? () => Navigator.maybePop(context),
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.primary,
        ),
        tooltip: 'Voltar',
      );
    }

    if (showSearchButton) {
      return IconButton(
        onPressed: onSearch,
        icon: const Icon(Icons.search, color: Color(0xFF232323), size: 24),
        tooltip: 'Pesquisar',
      );
    }

    return null;
  }
}
