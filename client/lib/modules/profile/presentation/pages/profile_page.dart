import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/impact/impact_repository.dart';
import '../../../../core/impact/impact_store.dart';
import '../../../../core/notifications/notifications_store.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_impact_row.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_status_pill.dart';
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
  late final ImpactStore _impactStore;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _profileStore = Modular.get<ProfileStore>();
    _impactStore = Modular.get<ImpactStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final token = _loginStore.authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    await Future.wait([
      _profileStore.load(token),
      _impactStore.loadPlatform(token),
    ]);
  }

  void _signOut() {
    _profileStore.clear();
    Modular.get<NotificationsStore>().clear();
    _loginStore.signOut();
    Modular.to.navigate(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(),
      bottomNavigationBar: AppMainNavigation(
        key: const Key('profile_bottom_navigation'),
        currentItem: AppNavigationItem.profile,
        profileStore: _profileStore,
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
                return AppErrorView(
                  message: _profileStore.errorMessage!,
                  onRetry: _loadProfile,
                  secondaryActionLabel: 'Voltar ao login',
                  onSecondaryAction: _signOut,
                );
              }

              if (profile == null) {
                return const SizedBox.shrink();
              }

              return _ProfileContent(
                profile: profile,
                impact: _impactStore.platform,
                onSignOut: _signOut,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.impact,
    required this.onSignOut,
  });

  final UserProfile profile;
  final PlatformImpact? impact;
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
          const AppSectionTitle('Utilitários'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: profile.isAdmin
                ? [
                    Expanded(
                      child: _UtilityItem(
                        key: const Key('admin_news_option'),
                        icon: Icons.assignment_ind_outlined,
                        label: 'Notícias',
                        onTap: () => Modular.to.navigate(AppRoutes.news),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(child: _ongValidationItem(AppRoutes.ongReviews)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _UtilityItem(
                        key: const Key('admin_needs_option'),
                        icon: Icons.label_outline,
                        label: 'Necessidades',
                        onTap: () => Modular.to.pushNamed(AppRoutes.needsAdmin),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: _UtilityItem(
                        key: const Key('registered_people_option'),
                        iconAsset: 'assets/icons/profile/registered_people.svg',
                        label: 'Pessoas\nCadastradas',
                        onTap: () =>
                            Modular.to.pushNamed(AppRoutes.assistedPeople),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _ongValidationItem(AppRoutes.ongValidation),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _UtilityItem(
                        key: const Key('volunteer_option'),
                        iconAsset: 'assets/icons/profile/volunteer.png',
                        isRaster: true,
                        label: 'Voluntário',
                        onTap: () =>
                            Modular.to.pushNamed(AppRoutes.volunteerActions),
                      ),
                    ),
                  ],
          ),
          const SizedBox(height: 20),
          if (!profile.isAdmin) ..._impact(),
          const AppSectionTitle('Configurações'),
          const SizedBox(height: 8),
          _SettingsAction(
            label: 'Conta',
            onTap: () => Modular.to.pushNamed(AppRoutes.profileEdit),
          ),
          const _SettingsAction(label: 'Fale Conosco'),
          _SettingsAction(
            label: 'Sobre',
            onTap: () => Modular.to.pushNamed(AppRoutes.aboutConfig),
          ),
          _SettingsAction(label: 'Sair', onTap: onSignOut),
        ],
      ),
    );
  }

  Widget _ongValidationItem(String route) {
    return _UtilityItem(
      key: const Key('ong_validation_option'),
      iconAsset: 'assets/icons/profile/ong_validation.svg',
      label: 'Validação para\nONG’s',
      onTap: () => Modular.to.pushNamed(route),
    );
  }

  List<Widget> _impact() {
    return [
      const AppSectionTitle('Nosso Impacto em Números'),
      const SizedBox(height: 10),
      AppImpactRow(
        items: [
          (impact?.registered, 'Vidas Registradas'),
          (impact?.inCare, 'Vidas em Cuidado'),
          (impact?.newBeginnings, 'Novos recomeços'),
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
    ];
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(radius: 34, imageUrl: profile.profileImage),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile.isAdmin)
                const AppStatusPill(
                  key: Key('profile_role_badge'),
                  label: 'Administrador',
                  color: Colors.white,
                  background: AppColors.danger,
                )
              else if (profile.isOng)
                AppStatusPill(
                  key: const Key('profile_role_badge'),
                  label: 'ONG',
                  color: Colors.white,
                  background: Theme.of(context).colorScheme.primary,
                ),
              if (profile.isAdmin || profile.isOng) const SizedBox(height: 4),
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

class _UtilityItem extends StatelessWidget {
  const _UtilityItem({
    required this.label,
    super.key,
    this.iconAsset,
    this.icon,
    this.isRaster = false,
    this.onTap,
  }) : assert(iconAsset != null || icon != null);

  final String? iconAsset;
  final IconData? icon;
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
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 44)
                : isRaster
                ? Image.asset(iconAsset!, width: 48, height: 48)
                : SvgPicture.asset(iconAsset!, width: 43, height: 43),
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
