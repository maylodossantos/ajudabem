import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'ajuda_bem_logo.dart';

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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: SvgPicture.asset(
            'assets/icons/notify_icon.svg',
            width: 32,
            height: 32,
          ),
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        onPressed: onBack,
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
