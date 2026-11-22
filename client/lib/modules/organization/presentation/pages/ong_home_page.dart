import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/geo/geo_point.dart';
import '../../../../core/impact/impact_store.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_impact_row.dart';
import '../../../../core/widgets/app_map.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_utility_tile.dart';
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
                  _FocusMapCard(
                    cases: _urgent.visibleCases
                        .where((person) => person.hasLocation)
                        .toList(),
                    onOpen: () => _go(AppRoutes.careMap),
                  ),
                  const SizedBox(height: 18),
                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSectionTitle('Utilitários'),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            Expanded(
                              child: AppUtilityTile(
                                iconAsset: AppIcons.nominatedPeople,
                                label: 'Pessoas\nindicadas',
                                onTap: () => _go(AppRoutes.nominatedPeople),
                              ),
                            ),
                            Expanded(
                              child: AppUtilityTile(
                                iconAsset: AppIcons.inCare,
                                label: 'Em\natendimento',
                                onTap: () => _go(AppRoutes.peopleInCare),
                              ),
                            ),
                            Expanded(
                              child: AppUtilityTile(
                                iconAsset: AppIcons.initiatives,
                                label: 'Iniciativas',
                                onTap: () => _go(AppRoutes.initiatives),
                              ),
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
                      child: const Text('Ver todos os urgentes'),
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
    final white = GoogleFonts.manrope(
      color: Colors.white,
      fontSize: AppTextSize.small,
    );

    return Material(
      color: Theme.of(context).colorScheme.primary,
      elevation: 3,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                  fontSize: AppTextSize.heading,
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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
        AppAvatar(radius: 46, imageUrl: imageUrl, placeholderIcon: null),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              color: Color(0xFF3B8FE8),
              size: 22,
            ),
          ),
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
            fontSize: AppTextSize.heading,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            color: AppColors.textStrong,
            fontSize: AppTextSize.heading,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _FocusMapCard extends StatelessWidget {
  const _FocusMapCard({required this.cases, required this.onOpen});

  final List<CareCase> cases;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final points = [
      for (final person in cases) LatLng(person.latitude!, person.longitude!),
    ];
    final count = cases.length;

    return Material(
      key: const Key('ong_home_focus_map'),
      color: primary,
      elevation: 3,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: points.isEmpty
                        ? AppMap.cascavel
                        : points.first,
                    initialZoom: AppMap.cityZoom,
                    backgroundColor: AppMap.tileBackground,
                    initialCameraFit: points.length > 1
                        ? CameraFit.coordinates(
                            coordinates: points,
                            padding: const EdgeInsets.all(28),
                            maxZoom: AppMap.streetZoom,
                          )
                        : null,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    AppMap.tileLayer(),
                    CircleLayer(
                      circles: [
                        for (final point in points)
                          CircleMarker(
                            point: point,
                            radius: 300,
                            useRadiusInMeter: true,
                            color: Urgency.high.color.withValues(alpha: 0.35),
                            borderColor: Urgency.high.color,
                            borderStrokeWidth: 1.5,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mapa de focos',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: AppTextSize.heading,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          count == 0
                              ? 'Veja onde estão as pessoas que precisam de ajuda.'
                              : count == 1
                              ? '1 caso urgente aguardando uma ONG.'
                              : '$count casos urgentes aguardando uma ONG.',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: AppTextSize.small,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Abrir mapa',
                      style: GoogleFonts.manrope(
                        color: primary,
                        fontSize: AppTextSize.small,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
