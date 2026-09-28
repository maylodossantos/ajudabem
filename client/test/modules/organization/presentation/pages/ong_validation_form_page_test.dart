import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/presentation/pages/ong_validation_form_page.dart';
import 'package:ajuda_bem/modules/organization/presentation/stores/organization_form_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../organization_test_doubles.dart';

void main() {
  Future<OrganizationFormStore> pumpForm(
    WidgetTester tester, {
    Organization? previous,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final store = OrganizationFormStore(
      FakeOrganizationRepository(),
      FakeDocumentPicker(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: OngValidationFormPage(store: store, previous: previous),
      ),
    );
    return store;
  }

  FilledButton button(WidgetTester tester, String key) =>
      tester.widget<FilledButton>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(FilledButton),
        ),
      );

  testWidgets('the data step keeps "Continuar" disabled until complete', (
    tester,
  ) async {
    await pumpForm(tester);

    expect(find.text('Razão Social:'), findsOneWidget);
    expect(find.text('CNPJ:'), findsOneWidget);
    expect(button(tester, 'ong_form_continue_button').onPressed, isNull);
  });

  testWidgets('a resubmission goes straight on to the documents', (
    tester,
  ) async {
    final store = await pumpForm(tester, previous: organizationWith());

    expect(button(tester, 'ong_form_continue_button').onPressed, isNotNull);
    final continueButton = find.byKey(const Key('ong_form_continue_button'));
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();

    expect(store.step, OrganizationFormStoreBase.documentsStep);
    for (final type in OrganizationDocumentType.values) {
      expect(find.text('${type.label}:'), findsOneWidget);
    }
    expect(button(tester, 'ong_form_submit_button').onPressed, isNull);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pump();
    expect(store.step, OrganizationFormStoreBase.dataStep);
  });
}
