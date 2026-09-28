import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppNavigationItem { news, help, profile, register, createNews, ong }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentItem,
    super.key,
    this.onNews,
    this.onHelp,
    this.onProfile,
    this.onRegister,
    this.showCreateNews = false,
    this.onCreateNews,
    this.showOng = false,
    this.onOng,
  });

  final AppNavigationItem currentItem;
  final VoidCallback? onNews;
  final VoidCallback? onHelp;
  final VoidCallback? onProfile;
  final VoidCallback? onRegister;

  final bool showCreateNews;
  final VoidCallback? onCreateNews;

  final bool showOng;
  final VoidCallback? onOng;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        border: Border(top: BorderSide(color: Color(0xFFE2E2E2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/news.svg',
                label: 'Notícias',
                selected: currentItem == AppNavigationItem.news,
                onTap: onNews,
              ),
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/heart.svg',
                label: 'Ajuda',
                selected: currentItem == AppNavigationItem.help,
                onTap: onHelp,
              ),
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/profile.svg',
                label: 'Perfil',
                selected: currentItem == AppNavigationItem.profile,
                onTap: onProfile,
              ),
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/add.svg',
                label: 'Cadastro',
                selected: currentItem == AppNavigationItem.register,
                onTap: onRegister,
              ),
              if (showCreateNews)
                _NavigationButton(
                  icon: Icons.campaign_outlined,
                  label: 'Publicar',
                  selected: currentItem == AppNavigationItem.createNews,
                  onTap: onCreateNews,
                ),
              if (showOng)
                _NavigationButton(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Ong',
                  selected: currentItem == AppNavigationItem.ong,
                  onTap: onOng,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.selected,
    this.iconAsset,
    this.icon,
    this.onTap,
  });

  final String? iconAsset;
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF494949);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null
                  ? Icon(icon, size: 22, color: color)
                  : SvgPicture.asset(
                      iconAsset!,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
