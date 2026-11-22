import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/impact/impact_repository.dart';
import '../../../../core/impact/impact_store.dart';
import '../../../../core/notifications/notifications_store.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_impact_row.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_utility_tile.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../organization/presentation/stores/organization_validation_store.dart';
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
  late final OrganizationValidationStore _organizationStore;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _profileStore = Modular.get<ProfileStore>();
    _impactStore = Modular.get<ImpactStore>();
    _organizationStore = Modular.get<OrganizationValidationStore>();
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
    if (_profileStore.profile?.isOng ?? false) {
      await _organizationStore.load(token);
    }
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
                organizationName: _organizationStore.organization?.tradeName,
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
    this.organizationName,
  });

  final UserProfile profile;
  final PlatformImpact? impact;
  final String? organizationName;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 32, 25, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileIdentity(
            profile: profile,
            organizationName: organizationName,
          ),
          const SizedBox(height: 30),
          const AppSectionTitle('Utilitários'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: profile.isAdmin
                ? [
                    Expanded(
                      child: AppUtilityTile(
                        key: const Key('admin_news_option'),
                        iconAsset: AppIcons.news,
                        label: 'Gerenciar\nnotícias',
                        onTap: () => Modular.to.pushNamed(AppRoutes.newsManage),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _ongValidationItem(
                        AppRoutes.ongReviews,
                        AppIcons.validationReview,
                        'Avaliar\nONGs',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: AppUtilityTile(
                        key: const Key('admin_needs_option'),
                        iconAsset: AppIcons.needs,
                        label: 'Tipos de\nnecessidade',
                        onTap: () => Modular.to.pushNamed(AppRoutes.needsAdmin),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: AppUtilityTile(
                        key: const Key('registered_people_option'),
                        iconAsset: AppIcons.registeredPeople,
                        label: 'Pessoas\ncadastradas',
                        onTap: () =>
                            Modular.to.pushNamed(AppRoutes.assistedPeople),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: profile.isOng
                          ? AppUtilityTile(
                              key: const Key('my_ong_option'),
                              iconAsset: AppIcons.myOng,
                              label: 'Minha ONG',
                              onTap: () =>
                                  Modular.to.pushNamed(AppRoutes.myOng),
                            )
                          : _ongValidationItem(
                              AppRoutes.ongValidation,
                              AppIcons.validationRequest,
                              'Cadastrar\nminha ONG',
                            ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: AppUtilityTile(
                        key: const Key('volunteer_option'),
                        iconAsset: AppIcons.volunteer,
                        label: 'Minhas ações',
                        onTap: () =>
                            Modular.to.pushNamed(AppRoutes.volunteerActions),
                      ),
                    ),
                  ],
          ),
          const SizedBox(height: 20),
          if (!profile.isAdmin && !profile.isOng) ..._impact(),
          const AppSectionTitle('Configurações'),
          const SizedBox(height: 8),
          _SettingsAction(
            label: 'Meus dados',
            onTap: () => Modular.to.pushNamed(AppRoutes.profileEdit),
          ),
          const _SettingsAction(label: 'Fale conosco'),
          _SettingsAction(
            label: 'Sobre',
            onTap: () => Modular.to.pushNamed(AppRoutes.aboutConfig),
          ),
          _SettingsAction(label: 'Sair', onTap: onSignOut),
        ],
      ),
    );
  }

  Widget _ongValidationItem(String route, String iconAsset, String label) {
    return AppUtilityTile(
      key: const Key('ong_validation_option'),
      iconAsset: iconAsset,
      label: label,
      onTap: () => Modular.to.pushNamed(route),
    );
  }

  List<Widget> _impact() {
    return [
      const AppSectionTitle('Nosso impacto'),
      const SizedBox(height: 10),
      AppImpactRow(
        items: [
          (impact?.registered, 'Pessoas indicadas'),
          (impact?.inCare, 'Pessoas em atendimento'),
          (impact?.newBeginnings, 'Novos recomeços'),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Obrigado por fazer parte do Ajuda Bem. Juntos,\n'
        'transformamos vidas todos os dias.',
        style: GoogleFonts.manrope(
          color: AppColors.textBody,
          fontSize: AppTextSize.body,
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
            color: AppColors.textBody,
            fontSize: AppTextSize.caption,
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
  const _ProfileIdentity({required this.profile, this.organizationName});

  final UserProfile profile;
  final String? organizationName;

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
              if (profile.isAdmin) ...[
                const AppBadge(
                  key: Key('profile_role_badge'),
                  label: 'Administrador',
                  tone: AppTone.danger,
                  icon: Icons.shield_outlined,
                ),
                const SizedBox(height: 4),
              ],
              Text(
                profile.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: AppColors.textStrong,
                  fontSize: AppTextSize.title,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'ID: ${profile.id.toString().padLeft(7, '0')}',
                style: GoogleFonts.manrope(
                  color: AppColors.textMuted,
                  fontSize: AppTextSize.caption,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              if (profile.isOng) ...[
                const SizedBox(height: 6),
                _OngLink(name: organizationName),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OngLink extends StatelessWidget {
  const _OngLink({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final name = this.name;

    return Material(
      color: primary.withValues(alpha: 0.1),
      shape: const StadiumBorder(),
      child: InkWell(
        key: const Key('profile_ong_link'),
        customBorder: const StadiumBorder(),
        onTap: () => Modular.to.navigate(AppRoutes.ong),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_outlined, size: 16, color: primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name == null
                      ? 'Responsável pela ONG'
                      : 'Responsável por $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: primary,
                    fontSize: AppTextSize.caption,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: primary),
            ],
          ),
        ),
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
              fontSize: AppTextSize.body,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
