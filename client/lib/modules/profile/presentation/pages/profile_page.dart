import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/user_profile.dart';
import '../stores/profile_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final LoginStore _loginStore;
  late final ProfileStore _profileStore;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _profileStore = Modular.get<ProfileStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final token = _loginStore.authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    await _profileStore.load(token);
  }

  void _signOut() {
    _profileStore.clear();
    _loginStore.signOut();
    Modular.to.navigate(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(),
      bottomNavigationBar: AppBottomNavigation(
        key: const Key('profile_bottom_navigation'),
        currentItem: AppNavigationItem.profile,
        onRegister: () => Modular.to.navigate(AppRoutes.registrationMenu),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Observer(
            builder: (_) {
              final profile = _profileStore.profile;

              if (_profileStore.isLoading && profile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_profileStore.errorMessage != null && profile == null) {
                return _ProfileError(
                  message: _profileStore.errorMessage!,
                  onRetry: _loadProfile,
                  onSignOut: _signOut,
                );
              }

              if (profile == null) {
                return const SizedBox.shrink();
              }

              return _ProfileContent(profile: profile, onSignOut: _signOut);
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile, required this.onSignOut});

  final UserProfile profile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 32, 25, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileIdentity(profile: profile),
          const SizedBox(height: 30),
          const _SectionTitle('Utilitários'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _UtilityItem(
                  key: const Key('registered_people_option'),
                  iconAsset: 'assets/icons/profile/registered_people.svg',
                  label: 'Pessoas\nCadastradas',
                  onTap: () => Modular.to.pushNamed(AppRoutes.assistedPeople),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: _UtilityItem(
                  iconAsset: 'assets/icons/profile/ong_validation.svg',
                  label: 'Validação para\nONG’s',
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: _UtilityItem(
                  iconAsset: 'assets/icons/profile/volunteer.png',
                  isRaster: true,
                  label: 'Voluntário',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Nosso Impacto em Números'),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ImpactItem(value: '24', label: 'Vidas Registradas'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ImpactItem(value: '12', label: 'Vidas em Cuidado'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ImpactItem(value: '2', label: 'Novos recomeços'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Obrigado por fazer parte do Ajuda Bem. Juntos,\n'
            'transformamos vidas todos os dias.',
            style: GoogleFonts.manrope(
              color: const Color(0xFF454545),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— Equipe AjudaBem',
              style: GoogleFonts.manrope(
                color: const Color(0xFF454545),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Configurações'),
          const SizedBox(height: 8),
          const _SettingsAction(label: 'Conta'),
          const _SettingsAction(label: 'Fale Conosco'),
          const _SettingsAction(label: 'Sobre'),
          _SettingsAction(label: 'Sair', onTap: onSignOut),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xFFD9D9D9),
          child: Icon(Icons.person_outline, size: 36, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF232323),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'ID: ${profile.id.toString().padLeft(7, '0')}',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFA2A2A2),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _UtilityItem extends StatelessWidget {
  const _UtilityItem({
    required this.iconAsset,
    required this.label,
    super.key,
    this.isRaster = false,
    this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool isRaster;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        children: [
          Container(
            height: 68,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: isRaster
                ? Image.asset(iconAsset, width: 48, height: 48)
                : SvgPicture.asset(iconAsset, width: 43, height: 43),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: Colors.black,
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  const _ImpactItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: const Color(0xFF232323),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 23,
        width: double.infinity,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
            TextButton(
              onPressed: onSignOut,
              child: const Text('Voltar ao login'),
            ),
          ],
        ),
      ),
    );
  }
}
