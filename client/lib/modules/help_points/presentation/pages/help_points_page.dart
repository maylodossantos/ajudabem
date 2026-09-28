import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_info_banner.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_square_icon_button.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_filter.dart';
import '../stores/help_points_store.dart';
import '../widgets/help_point_widgets.dart';

class HelpPointsPage extends StatefulWidget {
  const HelpPointsPage({super.key, this.store, this.canManage});

  final HelpPointsStore? store;
  final bool? canManage;

  @override
  State<HelpPointsPage> createState() => _HelpPointsPageState();
}

class _HelpPointsPageState extends State<HelpPointsPage> {
  late final HelpPointsStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<HelpPointsStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.load());
  }

  bool get _canManage =>
      widget.canManage ??
      (Modular.tryGet<ProfileStore>()?.profile?.isAdmin ?? false);

  Future<void> _openFilters() async {
    final filter = await Modular.to.pushNamed<HelpPointFilter>(
      AppRoutes.helpPointFilter,
      arguments: (_store.filter, _store.options),
    );
    if (filter != null) {
      await _store.applyFilter(filter);
    }
  }

  Future<void> _open(HelpPoint point) async {
    final changed = await Modular.to.pushNamed<bool>(
      AppRoutes.helpPointDetail,
      arguments: point,
    );
    if (changed == true && mounted) {
      await _store.load();
    }
  }

  Future<void> _create() async {
    final created = await Modular.to.pushNamed<bool>(AppRoutes.helpPointForm);
    if (created == true && mounted) {
      await _store.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(),
      bottomNavigationBar: const AppMainNavigation(
        currentItem: AppNavigationItem.help,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Observer(
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pontos de ajuda',
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF232323),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        if (_canManage) ...[
                          AppSquareIconButton(
                            key: const Key('help_points_add_button'),
                            icon: Icons.add,
                            tooltip: 'Cadastrar ponto de ajuda',
                            onPressed: _create,
                          ),
                          const SizedBox(width: 8),
                        ],
                        AppSquareIconButton(
                          icon: _store.showAsGrid
                              ? Icons.view_agenda_outlined
                              : Icons.grid_view,
                          tooltip: _store.showAsGrid
                              ? 'Mostrar em lista'
                              : 'Mostrar em grade',
                          onPressed: _store.toggleView,
                        ),
                        const SizedBox(width: 8),
                        AppSquareIconButton(
                          key: const Key('help_points_filter_button'),
                          icon: Icons.tune,
                          tooltip: 'Filtros',
                          color: _store.filter.isEmpty ? null : Colors.white,
                          background: _store.filter.isEmpty
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          onPressed: _openFilters,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickFilters(store: _store),
                  if (_store.isLocating)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (_store.locationError case final error?
                      when _store.filter.needsLocation)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: AppInfoBanner(
                        icon: Icons.location_off_outlined,
                        message: error,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AppAsyncList<HelpPoint>(
                      items: _store.visiblePoints,
                      isLoading: _store.isLoading,
                      errorMessage: _store.errorMessage,
                      emptyMessage: _store.points.isEmpty
                          ? 'Nenhum ponto de ajuda cadastrado.'
                          : 'Nenhum ponto de ajuda com esses filtros.',
                      onRefresh: _store.load,
                      columns: _store.showAsGrid ? 2 : 1,
                      gridItemHeight: 215,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemBuilder: (_, point) => HelpPointCard(
                        point: point,
                        horizontal: !_store.showAsGrid,
                        distanceKm: _store.distanceKmTo(point),
                        onTap: () => _open(point),
                      ),
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

class _QuickFilters extends StatelessWidget {
  const _QuickFilters({required this.store});

  final HelpPointsStore store;

  static const _shelter = {AssistanceType.shelter, AssistanceType.overnight};
  static const _health = {AssistanceType.medical, AssistanceType.psychological};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (store.options.hasLocations)
            _QuickChip(
              label: 'Próximos de você',
              selected: store.isNearbyActive,
              onTap: store.toggleNearby,
            ),
          if (store.options.offersAny(_shelter))
            _QuickChip(
              label: 'Albergue',
              selected: store.hasTypes(_shelter),
              onTap: () => store.toggleTypes(_shelter),
            ),
          if (store.options.organizationTypes.contains(
            HelpPointOrganizationType.ngo,
          ))
            _QuickChip(
              label: 'ONG’s',
              selected: store.hasOrganizationType(
                HelpPointOrganizationType.ngo,
              ),
              onTap: () =>
                  store.toggleOrganizationType(HelpPointOrganizationType.ngo),
            ),
          if (store.options.offersAny(_health))
            _QuickChip(
              label: 'Saúde',
              selected: store.hasTypes(_health),
              onTap: () => store.toggleTypes(_health),
            ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 4),
      child: Material(
        color: selected ? const Color(0xFF1E9E47) : AppColors.success,
        elevation: 2,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 16, 7),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.circle,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
