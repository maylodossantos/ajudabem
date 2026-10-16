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
        hoverColor: primary.withValues(alpha: 0.04),
        splashColor: primary.withValues(alpha: 0.08),
        highlightColor: primary.withValues(alpha: 0.06),
        child: SizedBox(
          height: 118,
          child: Row(
            children: [
              Container(
                width: 112,
                decoration: const BoxDecoration(
                  color: Color(0xFFD6F3EE),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(illustration, fit: BoxFit.contain),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF232323),
                          fontSize: 13,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right, color: primary, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
