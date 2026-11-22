import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point_filter.dart';
import 'package:ajuda_bem/modules/help_points/presentation/pages/help_point_filter_page.dart';
import 'package:ajuda_bem/modules/help_points/presentation/pages/help_points_page.dart';
import 'package:ajuda_bem/modules/help_points/presentation/stores/help_points_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../help_point_test_doubles.dart';

void main() {
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows the tapped point card on the map, toggles to the list', (
    tester,
  ) async {
    useTallScreen(tester);
    final store = HelpPointsStore(
      FakeHelpPointRepository(
        points: [
          helpPoint(id: 1, location: cascavelCenter),
          helpPoint(
            id: 2,
            name: 'UPA Veneza',
            services: [AssistanceType.medical],
            organizationType: HelpPointOrganizationType.publicHealth,
          ),
        ],
      ),
      FakeLocationService(position: cascavelCenter),
    );

    Future<void> pump({required bool admin}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HelpPointsPage(
            store: store,
            canManage: admin,
            showTiles: false,
          ),
        ),
      );
      await tester.pump();
    }

    await pump(admin: false);
    expect(find.text('Ver lista'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.byKey(const Key('help_point_marker_1')), findsOneWidget);
    expect(find.byKey(const Key('help_point_marker_2')), findsNothing);
    expect(find.text('Ver detalhes →'), findsNothing);

    await tester.tap(find.byKey(const Key('help_point_marker_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('help_point_card_1')), findsOneWidget);
    expect(find.byKey(const Key('help_point_card_2')), findsNothing);
    expect(find.text('Ver detalhes →'), findsOneWidget);
    expect(find.byKey(const Key('help_points_add_button')), findsNothing);

    await tester.tap(find.byKey(const Key('help_points_view_toggle')));
    await tester.pump();
    expect(find.byKey(const Key('help_point_list_1')), findsOneWidget);
    expect(find.byKey(const Key('help_point_list_2')), findsOneWidget);
    expect(find.text('Ver detalhes →'), findsNothing);
    expect(find.text('Ver mapa'), findsOneWidget);

    await tester.tap(find.byKey(const Key('help_points_view_toggle')));
    await tester.pump();
    expect(find.byKey(const Key('help_point_marker_1')), findsOneWidget);
    expect(find.byKey(const Key('help_point_card_1')), findsOneWidget);

    await pump(admin: true);
    expect(find.byKey(const Key('help_points_add_button')), findsOneWidget);
  });

  testWidgets('the filter screen returns the choices only on "Salvar"', (
    tester,
  ) async {
    useTallScreen(tester);
    HelpPointFilter? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<HelpPointFilter>(
                MaterialPageRoute(
                  builder: (_) => HelpPointFilterPage(
                    initial: const HelpPointFilter(),
                    options: HelpPointOptions.from([
                      helpPoint(
                        services: [AssistanceType.food],
                        openingHours: everyDay(0, 0),
                        location: cascavelCenter,
                      ),
                    ], monday),
                  ),
                ),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Tipo de local'), findsOneWidget);
    expect(find.text('Sem limite'), findsOneWidget);
    for (final option in ['Alimentação', 'Aberto agora', 'Mais próximos']) {
      await tester.ensureVisible(find.text(option));
      await tester.tap(find.text(option));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('filter_save_button')));
    await tester.pumpAndSettle();

    expect(result!.types, {AssistanceType.food});
    expect(result!.availability, {HelpPointAvailability.openNow});
    expect(result!.sort, HelpPointSort.nearest);
    expect(result!.maxDistanceKm, isNull);
  });
}
