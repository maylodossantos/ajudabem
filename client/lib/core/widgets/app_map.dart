import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../geo/geo_point.dart';
import '../services/last_location_store.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import 'app_feedback.dart';

class AppMap extends StatefulWidget {
  const AppMap({
    required this.controller,
    required this.layers,
    super.key,
    this.initialCenter = cascavel,
    this.initialZoom = AppMap.cityZoom,
    this.showTiles = true,
    this.isLoading = false,
    this.onTapEmpty,
    this.onReady,
    this.top,
    this.topHeight = 64,
    this.actions = const [],
    this.selected,
    this.showMyLocation = true,
    this.locationService,
    this.centerOnMe = true,
    this.onLocated,
    this.bottomCenter,
    this.lastLocationStore,
  });

  static const cascavel = LatLng(-24.9555, -53.4552);
  static const cityZoom = 14.0;
  static const streetZoom = 15.5;
  static const closeZoom = 16.5;

  final MapController controller;
  final List<Widget> layers;
  final LatLng initialCenter;
  final double initialZoom;
  final bool showTiles;
  final bool isLoading;
  final VoidCallback? onTapEmpty;
  final VoidCallback? onReady;
  final Widget? top;
  final double topHeight;
  final List<Widget> actions;
  final Widget? selected;
  final bool showMyLocation;
  final LocationService? locationService;
  final bool centerOnMe;
  final ValueChanged<LatLng>? onLocated;
  final Widget? bottomCenter;
  final LastLocationStore? lastLocationStore;

  @visibleForTesting
  static void forgetLastLocation() => _AppMapState._lastKnown = null;

  static Future<void> preloadLastLocation([
    LastLocationStore store = const SharedPrefsLastLocationStore(),
  ]) async {
    final point = await store.read();
    if (point == null) return;
    _AppMapState._lastKnown ??= LatLng(point.latitude, point.longitude);
  }

  static TileLayer tileLayer() => TileLayer(
    urlTemplate:
        'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.ajuda_bem',
    keepBuffer: 4,
    panBuffer: 1,
    tileDisplay: const TileDisplay.fadeIn(
      duration: Duration(milliseconds: 120),
      startOpacity: 0.4,
      reloadStartOpacity: 1,
    ),
    evictErrorTileStrategy: EvictErrorTileStrategy.notVisibleRespectMargin,
  );

  static const tileBackground = Color(0xFFF2F2F0);

  static LatLng toLatLng(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> with SingleTickerProviderStateMixin {
  static const _meZoom = AppMap.streetZoom;
  static LatLng? _lastKnown;

  late final _camera = AppMapCamera(controller: widget.controller, vsync: this);
  LatLng? _me;
  Future<LatLng>? _locating;
  bool _movedByUser = false;

  LastLocationStore get _saved =>
      widget.lastLocationStore ??
      Modular.tryGet<LastLocationStore>() ??
      const SharedPrefsLastLocationStore();

  LocationService get _location =>
      widget.locationService ??
      Modular.tryGet<LocationService>() ??
      const GeolocatorLocationService();

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _found(LatLng me) {
    if (!mounted) return;
    setState(() => _me = me);
    widget.onLocated?.call(me);
  }

  Future<LatLng> _locate() => _locating ??= () async {
    try {
      final point = await _location.currentPosition();
      final me = _lastKnown = LatLng(point.latitude, point.longitude);
      _saved.save(point).ignore();
      _found(me);
      return me;
    } finally {
      _locating = null;
    }
  }();

  void _onReady() {
    widget.onReady?.call();
    if (widget.showMyLocation) _startLocating().ignore();
  }

  Future<void> _startLocating() async {
    final known = _lastKnown ?? await _readSaved();
    if (!mounted) return;
    if (known != null) {
      _lastKnown ??= known;
      _found(known);
      if (widget.centerOnMe && !_movedByUser) {
        widget.controller.move(known, _meZoom);
      }
    }

    for (final wait in const [Duration.zero, Duration(seconds: 3)]) {
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      if (!mounted) return;
      try {
        final me = await _locate();
        if (mounted && widget.centerOnMe && !_movedByUser) {
          _camera.animateTo(me, _meZoom);
        }
        return;
      } catch (_) {
        continue;
      }
    }
  }

  Future<LatLng?> _readSaved() async {
    final point = await _saved.read();
    return point == null ? null : LatLng(point.latitude, point.longitude);
  }

  void _onMoved(MapCamera _, bool hasGesture) {
    if (hasGesture) _movedByUser = true;
  }

  Future<void> _centerOnMe() async {
    _movedByUser = false;
    if (_me case final known?) _camera.animateTo(known, _meZoom);
    try {
      final me = await _locate();
      if (mounted && !_movedByUser) _camera.animateTo(me, _meZoom);
    } catch (error) {
      if (mounted && _me == null) showAppSnackBar(context, '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppMap(
      :controller,
      :layers,
      :initialCenter,
      :initialZoom,
      :showTiles,
      :isLoading,
      :onTapEmpty,
      :top,
      :topHeight,
      :actions,
    ) = widget;
    final card = widget.selected;
    final me = _me;
    final startAtMe =
        widget.showMyLocation && widget.centerOnMe && _lastKnown != null;

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: startAtMe ? _lastKnown! : initialCenter,
            initialZoom: startAtMe ? _meZoom : initialZoom,
            backgroundColor: AppMap.tileBackground,
            onTap: (_, _) => onTapEmpty?.call(),
            onMapReady: _onReady,
            onPositionChanged: _onMoved,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            if (showTiles) AppMap.tileLayer(),
            if (me != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: me,
                    width: AppMapMyLocation.size,
                    height: AppMapMyLocation.size,
                    child: const AppMapMyLocation(key: Key('map_my_location')),
                  ),
                ],
              ),
            ...layers,
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                color: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const Text(
                  '© Stadia Maps · © OpenMapTiles · © OpenStreetMap',
                  style: TextStyle(fontSize: AppTextSize.caption),
                ),
              ),
            ),
          ],
        ),
        if (top case final top?)
          Positioned(left: 0, right: 0, top: 0, child: top),
        if (isLoading)
          Positioned(
            top: top == null ? 0 : topHeight,
            left: 0,
            right: 0,
            child: const LinearProgressIndicator(),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, card == null ? 24 : 12),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ?widget.bottomCenter,
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final action in actions) ...[
                            action,
                            const SizedBox(height: 14),
                          ],
                          AppMapButton(
                            key: const Key('map_center_me'),
                            icon: Icons.my_location,
                            tooltip: 'Minha localização',
                            onTap: _centerOnMe,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ?card,
            ],
          ),
        ),
      ],
    );
  }
}

class AppMapCamera {
  AppMapCamera({required this.controller, required TickerProvider vsync})
    : _animation = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 450),
      );

  final MapController controller;
  final AnimationController _animation;
  VoidCallback? _tick;

  void animateTo(LatLng center, double zoom) {
    final from = controller.camera;
    final latitude = Tween(begin: from.center.latitude, end: center.latitude);
    final longitude = Tween(
      begin: from.center.longitude,
      end: center.longitude,
    );
    final scale = Tween(begin: from.zoom, end: zoom);

    if (_tick case final previous?) _animation.removeListener(previous);
    final tick = _tick = () {
      final t = Curves.easeInOutCubic.transform(_animation.value);
      controller.move(
        LatLng(latitude.transform(t), longitude.transform(t)),
        scale.transform(t),
      );
    };
    _animation
      ..addListener(tick)
      ..forward(from: 0);
  }

  void dispose() => _animation.dispose();
}

class AppMapButton extends StatelessWidget {
  const AppMapButton({
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

class AppMapMyLocation extends StatelessWidget {
  const AppMapMyLocation({super.key});

  static const size = 44.0;
  static const color = Color(0xFF1A73E8);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Você está aqui',
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}

class AppMapPin extends StatelessWidget {
  const AppMapPin({
    required this.color,
    required this.icon,
    super.key,
    this.selected = false,
  });

  static const size = 48.0;

  final Color color;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final head = selected ? 40.0 : 32.0;

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: head,
            height: head,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: selected ? 3 : 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: head * 0.55),
          ),
          CustomPaint(size: const Size(12, 7), painter: _PinTipPainter(color)),
        ],
      ),
    );
  }
}

class _PinTipPainter extends CustomPainter {
  const _PinTipPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTipPainter oldDelegate) => oldDelegate.color != color;
}

class AppMapSheet extends StatelessWidget {
  const AppMapSheet({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: AppColors.surface,
            elevation: 6,
            shadowColor: Colors.black38,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
