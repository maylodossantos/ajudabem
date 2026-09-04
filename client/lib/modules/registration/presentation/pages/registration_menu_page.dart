import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/auth_app_bar.dart';

class RegistrationMenuPage extends StatelessWidget {
  const RegistrationMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showSearchButton: true),
      bottomNavigationBar: AppBottomNavigation(
        key: const Key('registration_menu_bottom_navigation'),
        currentItem: AppNavigationItem.register,
        onProfile: () => Modular.to.navigate(AppRoutes.profile),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ActionBanner(),
                  const SizedBox(height: 14),
                  Text(
                    'Formulários',
                    style: GoogleFonts.manrope(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Informe alguém que precisa de apoio — seja por falta de '
                    'moradia, alimento, saúde, dependências ou qualquer outra '
                    'necessidade urgente.',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF454545),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RegistrationOption(
                    onTap: () => Modular.to.pushNamed(
                      AppRoutes.vulnerablePersonRegistration,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 133,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            left: -13,
            bottom: 0,
            width: 168,
            child: Image.asset(
              'assets/images/forms/person.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 140,
            right: 16,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Um mundo melhor\nnasce de uma boa\nação.',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationOption extends StatelessWidget {
  const _RegistrationOption({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: double.infinity,
          height: 38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Cadastro de Pessoa em Vulnerabilidade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
