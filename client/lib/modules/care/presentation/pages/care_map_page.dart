import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_map.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/entities/care_map.dart';
import '../stores/care_map_store.dart';
import '../widgets/care_widgets.dart';

class CareMapPage extends StatefulWidget {
  const CareMapPage({super.key, this.store, this.token, this.showTiles = true});

  final CareMapStore? store;
  final String? token;
  final bool showTiles;

  @override
  State<CareMapPage> createState() => _CareMapPageState();
}

class _CareMapPageState extends State<CareMapPage> {
  late final CareMapStore _store;
  final _map = MapController();
  bool _onMe = false;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<CareMapStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(token);
    final first = _store.cases.where((person) => person.hasLocation);
    if (mounted && !_onMe && first.isNotEmpty) {
      _map.move(
        LatLng(first.first.latitude!, first.first.longitude!),
        AppMap.streetZoom,
      );
    }
  }

  Future<void> _assume() async {
    final token = _token;
    if (token == null) return;
    final ok = await _store.assumeSelected(token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? 'Atendimento assumido. Registre o primeiro andamento.'
          : _store.errorMessage ?? 'Não foi possível assumir.',
    );
  }

  void _openFocus(CareFocus focus) {
    _store.showPeople();
    _map.move(LatLng(focus.latitude, focus.longitude), AppMap.closeZoom);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.ong,
      maxWidth: double.infinity,
      body: Observer(
        builder: (_) {
          final selected = _store.selected;
          final foci = _store.mode == MapMode.foci;

          return AppMap(
            controller: _map,
            showTiles: widget.showTiles,
            isLoading: _store.isLoading,
            onTapEmpty: () => _store.select(null),
            onLocated: (_) => _onMe = true,
            top: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final layer in MapLayer.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppChoiceChip(
                          key: Key('map_layer_${layer.name}'),
                          label: layer.label,
                          selected: _store.layer == layer,
                          onTap: () => _store.setLayer(layer),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              AppMapButton(
                key: const Key('map_toggle_mode'),
                icon: foci ? Icons.person_outline : Icons.donut_large,
                tooltip: foci ? 'Ver pessoas' : 'Ver focos',
                onTap: _store.toggleMode,
              ),
            ],
            layers: [
              if (foci) ...[
                CircleLayer(
                  circles: [
                    for (final focus in _store.foci)
                      CircleMarker(
                        point: LatLng(focus.latitude, focus.longitude),
                        radius: 120.0 + 60 * focus.count,
                        useRadiusInMeter: true,
                        color: focus.urgency.color.withValues(alpha: 0.4),
                        borderColor: focus.urgency.color,
                        borderStrokeWidth: 1,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (final focus in _store.foci)
                      Marker(
                        point: LatLng(focus.latitude, focus.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          key: Key('focus_${focus.label}'),
                          onTap: () => _openFocus(focus),
                          child: Center(
                            child: Text(
                              '${focus.count}',
                              style: GoogleFonts.manrope(
                                color: AppColors.textStrong,
                                fontSize: AppTextSize.title,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ] else
                MarkerLayer(
                  markers: [
                    for (final person in _store.visible)
                      if (person.hasLocation)
                        Marker(
                          point: LatLng(person.latitude!, person.longitude!),
                          width: AppMapPin.size,
                          height: AppMapPin.size,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            key: Key('person_marker_${person.id}'),
                            onTap: () => _store.select(person),
                            child: AppMapPin(
                              color: person.id == selected?.id
                                  ? AppColors.textStrong
                                  : person.urgency.color,
                              icon: Icons.person,
                              selected: person.id == selected?.id,
                            ),
                          ),
                        ),
                  ],
                ),
            ],
            selected: selected == null
                ? null
                : _PersonSheet(
                    person: selected,
                    isAssuming: _store.isAssuming,
                    onOpen: () => Modular.to.pushNamed(
                      AppRoutes.careCase,
                      arguments: selected.id,
                    ),
                    onAssume: _assume,
                  ),
          );
        },
      ),
    );
  }
}

class _PersonSheet extends StatelessWidget {
  const _PersonSheet({
    required this.person,
    required this.isAssuming,
    required this.onOpen,
    required this.onAssume,
  });

  final CareCase person;
  final bool isAssuming;
  final VoidCallback onOpen;
  final VoidCallback onAssume;

  @override
  Widget build(BuildContext context) {
    final nominated = person.status == CareStatus.nominated;
    final organization = person.organizationName;

    return AppMapSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: AppColors.textStrong,
                        fontSize: AppTextSize.title,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    if (person.cityLabel.isNotEmpty)
                      Text(
                        person.cityLabel,
                        style: GoogleFonts.manrope(
                          color: AppColors.textSecondary,
                          fontSize: AppTextSize.small,
                          letterSpacing: 0,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              UrgencyBadge(urgency: person.urgency),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          NeedChips(needs: person.needs, maxVisible: 4),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.apartment_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  organization ?? 'Aguardando uma ONG',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: AppColors.textBody,
                    fontSize: AppTextSize.small,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (!nominated)
                AppBadge(
                  label: person.status.label,
                  tone: person.status == CareStatus.finished
                      ? AppTone.success
                      : AppTone.brand,
                  dot: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (nominated)
            AppCardActions(
              secondaryLabel: 'Ver detalhes',
              onSecondary: onOpen,
              primaryLabel: 'Assumir atendimento',
              primaryKey: const Key('map_assume'),
              isLoading: isAssuming,
              onPrimary: onAssume,
            )
          else
            AppCardButton(
              key: const Key('map_open_case'),
              label: 'Ver detalhes',
              onPressed: onOpen,
            ),
        ],
      ),
    );
  }
}
