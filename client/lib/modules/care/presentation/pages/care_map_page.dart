import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_feedback.dart';
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

  static const cascavel = LatLng(-24.9555, -53.4552);

  @override
  State<CareMapPage> createState() => _CareMapPageState();
}

class _CareMapPageState extends State<CareMapPage> {
  late final CareMapStore _store;
  final _map = MapController();

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
    if (mounted && first.isNotEmpty) {
      _map.move(LatLng(first.first.latitude!, first.first.longitude!), 13);
    }
  }

  Future<void> _centerOnMe() async {
    try {
      final point = await Modular.get<LocationService>().currentPosition();
      _map.move(LatLng(point.latitude, point.longitude), 14);
    } catch (error) {
      if (mounted) showAppSnackBar(context, '$error');
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
    _map.move(LatLng(focus.latitude, focus.longitude), 15);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.ong,
      maxWidth: double.infinity,
      body: Observer(
        builder: (_) {
          final selected = _store.selected;

          return Stack(
            children: [
              FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: CareMapPage.cascavel,
                  initialZoom: 13,
                  onTap: (_, _) => _store.select(null),
                ),
                children: [
                  if (widget.showTiles)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.ajuda_bem',
                    ),
                  if (_store.mode == MapMode.foci) ...[
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
                                    color: const Color(0xFF232323),
                                    fontSize: 15,
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
                              point: LatLng(
                                person.latitude!,
                                person.longitude!,
                              ),
                              width: 30,
                              height: 30,
                              child: GestureDetector(
                                key: Key('person_marker_${person.id}'),
                                onTap: () => _store.select(person),
                                child: _Dot(
                                  color: person.urgency.color,
                                  selected: person.id == selected?.id,
                                ),
                              ),
                            ),
                      ],
                    ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: const Text(
                        '© OpenStreetMap',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
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
              ),
              if (_store.isLoading)
                const Positioned(
                  top: 64,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
              Positioned(
                right: 16,
                bottom: selected == null ? 24 : 250,
                child: Column(
                  children: [
                    _RoundButton(
                      key: const Key('map_center_me'),
                      icon: Icons.my_location,
                      tooltip: 'Minha localização',
                      onTap: _centerOnMe,
                    ),
                    const SizedBox(height: 14),
                    _RoundButton(
                      key: const Key('map_toggle_mode'),
                      icon: _store.mode == MapMode.foci
                          ? Icons.person_outline
                          : Icons.donut_large,
                      tooltip: _store.mode == MapMode.foci
                          ? 'Ver pessoas'
                          : 'Ver focos',
                      onTap: _store.toggleMode,
                    ),
                  ],
                ),
              ),
              if (selected != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _PersonSheet(
                    person: selected,
                    isAssuming: _store.isAssuming,
                    onOpen: () => Modular.to.pushNamed(
                      AppRoutes.careCase,
                      arguments: selected.id,
                    ),
                    onAssume: _assume,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: selected ? 26 : 20,
        height: selected ? 26 : 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        tooltip: tooltip,
        iconSize: 30,
        padding: const EdgeInsets.all(14),
        color: Theme.of(context).colorScheme.primary,
        onPressed: onTap,
        icon: Icon(icon),
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
    final label = GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );
    final nominated = person.status == CareStatus.nominated;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAvatar(radius: 28, imageUrl: null),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullName,
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (person.cityLabel.isNotEmpty)
                      Text(
                        person.cityLabel,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFA2A2A2),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 4),
                    UrgencyBar(urgency: person.urgency, width: 110),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Necessidades:', style: label),
                    const SizedBox(height: 6),
                    NeedChips(needs: person.needs),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ONG Responsável:', style: label),
                    const SizedBox(height: 6),
                    Text(person.organizationName ?? 'Não atribuída.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCardActions(
            secondaryLabel: 'Ver detalhes',
            onSecondary: onOpen,
            primaryLabel: nominated ? 'Ajudar' : 'Em atendimento',
            primaryKey: const Key('map_assume'),
            primaryDone: !nominated,
            isLoading: isAssuming,
            onPrimary: onAssume,
          ),
        ],
      ),
    );
  }
}
