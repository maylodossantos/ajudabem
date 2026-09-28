import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_map.dart';
import 'package:ajuda_bem/modules/care/presentation/pages/care_map_page.dart';
import 'package:ajuda_bem/modules/care/presentation/stores/care_map_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../care_test_doubles.dart';

CareCase located(
  int id, {
  String neighborhood = 'Centro',
  Urgency urgency = Urgency.low,
  CareStatus status = CareStatus.nominated,
  double latitude = -24.95,
}) => CareCase(
  id: id,
  fullName: 'Pessoa $id',
  urgency: urgency,
  status: status,
  neighborhood: neighborhood,
  city: 'Cascavel',
  state: 'PR',
  latitude: latitude,
  longitude: -53.45,
  needs: const ['Alimentação'],
);

void main() {
  test('foci group people by neighborhood with the worst urgency', () {
    final foci = CareFocus.of([
      located(1),
      located(2, urgency: Urgency.high),
      located(3, neighborhood: 'São Cristóvão', latitude: -24.94),
      careCase(id: 4),
    ]);

    expect(foci, hasLength(2));
    final centro = foci.firstWhere((focus) => focus.label == 'Centro');
    expect(centro.count, 2);
    expect(centro.urgency, Urgency.high);
  });

  test('the layer chips filter what is on the map', () {
    final cases = [
      located(1, urgency: Urgency.high),
      located(2, status: CareStatus.inCare),
      located(3),
    ];

    expect(MapLayer.none.apply(cases), isEmpty);
    expect(MapLayer.all.apply(cases), hasLength(3));
    expect(MapLayer.urgent.apply(cases).single.id, 1);
    expect(MapLayer.inCare.apply(cases).single.id, 2);
  });

  testWidgets('people mode shows the person card and lets the ONG help', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = FakeCareRepository(nominatedCases: [located(1)]);
    final store = CareMapStore(repository);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CareMapPage(store: store, token: 'jwt', showTiles: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('map_toggle_mode')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('person_marker_1')));
    await tester.pumpAndSettle();
    expect(find.text('Pessoa 1'), findsOneWidget);
    expect(find.text('Não atribuída.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('map_assume')));
    await tester.pumpAndSettle();
    expect(repository.assumed, [1]);
    expect(find.text('Em atendimento'), findsWidgets);
  });
}
