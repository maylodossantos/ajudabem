import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/geo/geo_point.dart';
import 'package:ajuda_bem/core/services/last_location_store.dart';
import 'package:ajuda_bem/core/services/location_service.dart';
import 'package:ajuda_bem/core/widgets/app_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocation implements LocationService {
  _FakeLocation({this.position});

  final GeoPoint? position;
  int calls = 0;

  @override
  Future<GeoPoint> currentPosition() async {
    calls++;
    return position ?? (throw const AppException('Sem localização.'));
  }
}

class _FakeSaved implements LastLocationStore {
  _FakeSaved([this.point]);

  GeoPoint? point;

  @override
  Future<GeoPoint?> read() async => point;

  @override
  Future<void> save(GeoPoint point) async => this.point = point;
}

void main() {
  setUp(AppMap.forgetLastLocation);

  Future<MapController> pumpMap(
    WidgetTester tester,
    LocationService location, {
    LastLocationStore? saved,
  }) async {
    final controller = MapController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppMap(
            controller: controller,
            layers: const [],
            showTiles: false,
            locationService: location,
            lastLocationStore: saved ?? _FakeSaved(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('marks and centers on the person once the location arrives', (
    tester,
  ) async {
    final saved = _FakeSaved();
    final controller = await pumpMap(
      tester,
      _FakeLocation(position: const GeoPoint(-24.9, -53.4)),
      saved: saved,
    );

    expect(find.byKey(const Key('map_my_location')), findsOneWidget);
    expect(controller.camera.center.latitude, closeTo(-24.9, 0.0001));
    expect(controller.camera.center.longitude, closeTo(-53.4, 0.0001));
    expect(controller.camera.zoom, AppMap.streetZoom);
    expect(saved.point?.latitude, -24.9);
  });

  testWidgets('shows no marker and tries again when the location fails', (
    tester,
  ) async {
    final location = _FakeLocation();
    await pumpMap(tester, location);

    expect(find.byKey(const Key('map_my_location')), findsNothing);
    expect(location.calls, 2);
  });

  testWidgets('opens on the last saved position while the GPS is slow', (
    tester,
  ) async {
    final controller = await pumpMap(
      tester,
      _FakeLocation(),
      saved: _FakeSaved(const GeoPoint(-25.1, -53.2)),
    );

    expect(find.byKey(const Key('map_my_location')), findsOneWidget);
    expect(controller.camera.center.latitude, closeTo(-25.1, 0.0001));
  });

  testWidgets('starts on the preloaded position instead of the city center', (
    tester,
  ) async {
    await AppMap.preloadLastLocation(_FakeSaved(const GeoPoint(-25.3, -53.1)));
    final controller = MapController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppMap(
            controller: controller,
            layers: const [],
            showTiles: false,
            locationService: _FakeLocation(),
            lastLocationStore: _FakeSaved(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(controller.camera.center.latitude, closeTo(-25.3, 0.0001));
    expect(controller.camera.zoom, AppMap.streetZoom);

    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
