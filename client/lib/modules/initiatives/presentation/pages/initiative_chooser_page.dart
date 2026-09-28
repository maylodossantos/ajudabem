import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_page_scaffold.dart';

class InitiativeChooserPage extends StatelessWidget {
  const InitiativeChooserPage({super.key});

  Future<void> _open(BuildContext context, String route) async {
    final saved = await Modular.to.pushNamed<Object>(route);
    if (saved != null && context.mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AppPageScaffold(
      currentItem: AppNavigationItem.ong,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Escolha sua iniciativa',
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione o tipo de iniciativa que deseja criar no AjudaBem.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 15, letterSpacing: 0),
              ),
              const SizedBox(height: 28),
              _Option(
                key: const Key('choose_campaign'),
                illustration: 'assets/illustrations/campaign_megaphone.png',
                title: 'Campanha',
                description:
                    'Arrecade doações e mobilize pessoas para uma causa '
                    'importante.',
                onTap: () => _open(context, AppRoutes.campaignForm),
              ),
              const SizedBox(height: 16),
              _Option(
                key: const Key('choose_action'),
                illustration: 'assets/illustrations/volunteers.png',
                title: 'Ação voluntária',
                description:
                    'Organize voluntários e atividades para ajudar sua '
                    'comunidade.',
                onTap: () => _open(context, AppRoutes.actionForm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.illustration,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final String illustration;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              Container(
                width: 130,
                color: const Color(0xFFCFF2EC),
                padding: const EdgeInsets.all(14),
                child: Image.asset(illustration, fit: BoxFit.contain),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          color: primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.manrope(fontSize: 14, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
