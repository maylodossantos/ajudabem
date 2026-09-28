import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/geo/geo_point.dart';
import '../../../../core/impact/impact_store.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_impact_row.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../care/domain/entities/care_case.dart';
import '../../../care/domain/entities/care_filter.dart';
import '../../../care/presentation/stores/care_list_store.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../stores/organization_validation_store.dart';

class OngHomePage extends StatefulWidget {
  const OngHomePage({super.key});

  @override
  State<OngHomePage> createState() => _OngHomePageState();
}

class _OngHomePageState extends State<OngHomePage> {
  late final OrganizationValidationStore _store;
  late final ImpactStore _impact;
  late final CareListStore _urgent;

  static const _urgentFilter = CareFilter(urgencies: {Urgency.high});

  @override
  void initState() {
    super.initState();
    _store = Modular.get<OrganizationValidationStore>();
    _impact = Modular.get<ImpactStore>();
    _urgent = Modular.get<CareListStore>()..applyFilter(_urgentFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await Future.wait([
      _store.load(token),
      _impact.loadOrganization(token),
      _urgent.load(token, mode: CareListMode.nominated),
    ]);
  }

  Future<void> _go(String route, [Object? arguments]) async {
    await Modular.to.pushNamed(route, arguments: arguments);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Modular.get<ProfileStore>().profile;

    return AppPageScaffold(
      currentItem: AppNavigationItem.ong,
      showBackButton: false,
      maxWidth: 420,
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Observer(
            builder: (_) {
              final impact = _impact.organization;
              final urgent = _urgent.visibleCases.take(2).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WhiteCard(
                    child: Row(
                      children: [
                        _VerifiedAvatar(imageUrl: profile?.profileImage),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _Identity(
                            name:
                                _store.organization?.tradeName ??
                                profile?.name ??
                                '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSectionTitle('Impacto da ONG'),
                        const SizedBox(height: 12),
                        AppImpactRow(
                          items: [
                            (impact?.peopleHelped, 'Pessoas\nAjudadas'),
                            (impact?.volunteers, 'Voluntários'),
                            (impact?.campaignsFinished, 'Doações\nEntregues'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSectionTitle('Utilitários'),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                          children: [
                            _Tool(
                              iconAsset:
                                  'assets/icons/ong/nominated_people.png',
                              label: 'Pessoas\nIndicadas',
                              onTap: () => _go(AppRoutes.nominatedPeople),
                            ),
                            _Tool(
                              iconAsset: 'assets/icons/ong/people_in_care.png',
                              label: 'Pessoas em\nAtendimento',
                              onTap: () => _go(AppRoutes.peopleInCare),
                            ),
                            _Tool(
                              iconAsset: 'assets/icons/ong/initiatives.png',
                              label: 'Iniciativas',
                              onTap: () => _go(AppRoutes.initiatives),
                            ),
                            _Tool(
                              iconAsset: 'assets/icons/ong/focus_map.png',
                              label: 'Mapa de Focos',
                              onTap: () => _go(AppRoutes.careMap),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (urgent.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const AppSectionTitle('Casos urgentes próximos'),
                    const SizedBox(height: 10),
                    for (final person in urgent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UrgentCase(
                          person: person,
                          onTap: () => _go(AppRoutes.careCase, person.id),
                        ),
                      ),
                    TextButton(
                      key: const Key('ong_home_urgent_more'),
                      onPressed: () =>
                          _go(AppRoutes.nominatedPeople, _urgentFilter),
                      child: const Text('Ver casos urgentes...'),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UrgentCase extends StatelessWidget {
  const _UrgentCase({required this.person, required this.onTap});

  final CareCase person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final white = GoogleFonts.manrope(color: Colors.white, fontSize: 13.5);

    return Material(
      color: Theme.of(context).colorScheme.primary,
      elevation: 3,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.fullName,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Necessidade: ',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: person.needs.isEmpty
                          ? 'não informada'
                          : person.needs.join(', '),
                    ),
                  ],
                ),
                style: white,
              ),
              if (person.distanceKm case final km?)
                Text('A ${GeoPoint.formatKm(km)} da ONG', style: white),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _VerifiedAvatar extends StatelessWidget {
  const _VerifiedAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppAvatar(radius: 48, imageUrl: imageUrl),
        const Positioned(
          right: -2,
          bottom: 4,
          child: Icon(Icons.verified, color: Color(0xFF3B8FE8), size: 30),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ONG',
          style: GoogleFonts.manrope(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: const Color(0xFF232323),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(14),
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 6),
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
