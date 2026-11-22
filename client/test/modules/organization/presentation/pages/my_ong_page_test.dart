import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/presentation/pages/my_ong_page.dart';
import 'package:ajuda_bem/modules/organization/presentation/pages/ong_contact_form_page.dart';
import 'package:ajuda_bem/modules/organization/presentation/stores/organization_contact_store.dart';
import 'package:ajuda_bem/modules/organization/presentation/stores/organization_validation_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../organization_test_doubles.dart';

void main() {
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows the official data locked, the contact and documents', (
    tester,
  ) async {
    useTallScreen(tester);
    final store = OrganizationValidationStore(
      FakeOrganizationRepository(
        mine: organizationWith(status: OrganizationStatus.approved),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MyOngPage(store: store, token: 'token'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amigos dos Rios'), findsWidgets);
    expect(find.text('Dados oficiais'), findsOneWidget);
    expect(find.text('44.555.666/0001-81'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Contato e endereço'), findsOneWidget);
    expect(find.text('Rua das Flores, 123'), findsOneWidget);
    expect(find.byKey(const Key('my_ong_edit_contact')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Documentos'), 200);
    expect(find.text('Documentos'), findsOneWidget);
    expect(find.text('Estatuto Social'), findsOneWidget);
  });

  testWidgets('the contact form keeps "Salvar" off until the address is ok', (
    tester,
  ) async {
    useTallScreen(tester);
    final store = OrganizationContactStore(FakeOrganizationRepository());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: OngContactFormPage(
          organization: organizationWith(status: OrganizationStatus.approved),
          store: store,
          token: 'token',
        ),
      ),
    );

    FilledButton save() => tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('ong_contact_save_button')),
        matching: find.byType(FilledButton),
      ),
    );

    expect(find.text('Razão social'), findsNothing);
    expect(save().onPressed, isNotNull);

    store.setNumber('');
    await tester.pump();
    expect(save().onPressed, isNull);
  });
}
