import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppNavigationItem { news, help, profile, ong, register }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentItem,
    super.key,
    this.onNews,
    this.onHelp,
    this.onProfile,
    this.onRegister,
    this.showOng = false,
    this.onOng,
    this.signedIn = true,
  });

  final AppNavigationItem currentItem;
  final VoidCallback? onNews;
  final VoidCallback? onHelp;
  final VoidCallback? onProfile;
  final VoidCallback? onRegister;

  final bool showOng;
  final VoidCallback? onOng;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/inicio.svg',
                label: 'Início',
                selected: currentItem == AppNavigationItem.news,
                onTap: onNews,
              ),
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/mapa.svg',
                label: 'Ajuda',
                selected: currentItem == AppNavigationItem.help,
                onTap: onHelp,
              ),
              _NavigationButton(
                iconAsset: 'assets/icons/navigation/perfil.svg',
                label: signedIn ? 'Perfil' : 'Entrar',
                selected: currentItem == AppNavigationItem.profile,
                onTap: onProfile,
              ),
              if (showOng)
                _NavigationButton(
                  iconAsset: 'assets/icons/navigation/base_da_ong.svg',
                  label: 'ONG',
                  selected: currentItem == AppNavigationItem.ong,
                  onTap: onOng,
                ),
              if (signedIn)
                _NavigationButton(
                  iconAsset: 'assets/icons/navigation/cadastro.svg',
                  label: 'Indicar',
                  selected: currentItem == AppNavigationItem.register,
                  onTap: onRegister,
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
    required this.iconAsset,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : AppColors.textBody;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: color,
                  fontSize: AppTextSize.caption,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
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
