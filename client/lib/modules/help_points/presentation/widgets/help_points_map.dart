import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/geo/geo_point.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_map.dart';
import '../../domain/entities/help_point.dart';
import 'help_point_widgets.dart';

class HelpPointsMap extends StatefulWidget {
  const HelpPointsMap({
    required this.points,
    required this.onOpen,
    super.key,
    this.distanceKmTo,
    this.now,
    this.isLoading = false,
    this.showTiles = true,
    this.actions = const [],
    this.bottomCenter,
  });

  final List<HelpPoint> points;
  final ValueChanged<HelpPoint> onOpen;
  final double? Function(HelpPoint point)? distanceKmTo;
  final DateTime? now;
  final bool isLoading;
  final bool showTiles;
  final List<Widget> actions;
  final Widget? bottomCenter;

  @override
  State<HelpPointsMap> createState() => _HelpPointsMapState();
}

class _HelpPointsMapState extends State<HelpPointsMap>
    with SingleTickerProviderStateMixin {
  static const _startZoom = AppMap.streetZoom;
  static const _cardHeight = 132.0;

  final _map = MapController();
  late final _camera = AppMapCamera(controller: _map, vsync: this);
  bool _ready = false;
  bool _onMe = false;
  int? _index;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HelpPointsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.points.map((point) => point.id).join(',');
    final after = widget.points.map((point) => point.id).join(',');
    if (before == after) return;
    _index = null;
    _scheduleCenter();
  }

  void _onReady() {
    _ready = true;
    _scheduleCenter();
  }

  void _scheduleCenter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _center();
    });
  }

  GeoPoint _median() {
    final locations = [for (final point in widget.points) point.location!];
    final latitudes = locations.map((point) => point.latitude).toList()..sort();
    final longitudes = locations.map((point) => point.longitude).toList()
      ..sort();
    return GeoPoint(
      latitudes[latitudes.length ~/ 2],
      longitudes[longitudes.length ~/ 2],
    );
  }

  void _center() {
    if (!_ready || _onMe || widget.points.isEmpty) return;
    _map.move(AppMap.toLatLng(_median()), AppMap.cityZoom);
  }

  void _focus(HelpPoint point) {
    if (!_ready) return;
    final zoom = _map.camera.zoom < _startZoom ? _startZoom : _map.camera.zoom;
    _camera.animateTo(AppMap.toLatLng(point.location!), zoom);
  }

  void _onPinTap(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _focus(widget.points[index]);
  }

  void _close() {
    if (_index == null) return;
    setState(() => _index = null);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final primary = Theme.of(context).colorScheme.primary;

    return AppMap(
      controller: _map,
      showTiles: widget.showTiles,
      isLoading: widget.isLoading,
      onReady: _onReady,
      onTapEmpty: _close,
      onLocated: (_) => _onMe = true,
      actions: widget.actions,
      bottomCenter: widget.bottomCenter,
      layers: [
        MarkerLayer(
          markers: [
            for (final (index, point) in points.indexed)
              Marker(
                point: AppMap.toLatLng(point.location!),
                width: AppMapPin.size,
                height: AppMapPin.size,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  key: Key('help_point_marker_${point.id}'),
                  onTap: () => _onPinTap(index),
                  child: AppMapPin(
                    color: index == _index ? AppColors.textStrong : primary,
                    icon: HelpPointCover.iconOf(point),
                    selected: index == _index,
                  ),
                ),
              ),
          ],
        ),
      ],
      selected: switch (_index) {
        final index? when index < points.length => Align(
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SizedBox(
                height: _cardHeight,
                child: HelpPointMapCard(
                  key: Key('help_point_card_${points[index].id}'),
                  point: points[index],
                  now: widget.now,
                  distanceKm: widget.distanceKmTo?.call(points[index]),
                  onTap: () => widget.onOpen(points[index]),
                ),
              ),
            ),
          ),
        ),
        _ => null,
      },
    );
  }
}

class HelpPointMapCard extends StatelessWidget {
  const HelpPointMapCard({
    required this.point,
    required this.onTap,
    super.key,
    this.distanceKm,
    this.now,
  });

  final HelpPoint point;
  final VoidCallback onTap;
  final double? distanceKm;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final place = [
      point.neighborhood.isNotEmpty ? point.neighborhood : point.city,
      if (distanceKm case final km?) GeoPoint.formatKm(km),
    ].where((part) => part.isNotEmpty).join(' · ');
    final open = now != null && point.isOpenAt(now!);

    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: HelpPointCover(point: point, aspectRatio: 1, radius: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: AppColors.textStrong,
                        fontSize: AppTextSize.title,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                    if (place.isNotEmpty)
                      Text(
                        place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: AppColors.textSecondary,
                          fontSize: AppTextSize.caption,
                          letterSpacing: 0,
                        ),
                      ),
                    if (open)
                      Text(
                        'Aberto agora',
                        style: GoogleFonts.manrope(
                          color: AppColors.successText,
                          fontSize: AppTextSize.caption,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      'Ver detalhes →',
                      style: GoogleFonts.manrope(
                        color: primary,
                        fontSize: AppTextSize.small,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
