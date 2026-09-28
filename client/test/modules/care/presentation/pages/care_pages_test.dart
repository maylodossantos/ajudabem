import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/presentation/pages/care_case_page.dart';
import 'package:ajuda_bem/modules/care/presentation/pages/care_list_page.dart';
import 'package:ajuda_bem/modules/care/presentation/pages/care_record_form_page.dart';
import 'package:ajuda_bem/modules/care/presentation/stores/care_case_store.dart';
import 'package:ajuda_bem/modules/care/presentation/stores/care_list_store.dart';
import 'package:ajuda_bem/modules/care/presentation/stores/care_record_form_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/tags/seeded_tags.dart';
import '../../care_test_doubles.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: page));
    await tester.pumpAndSettle();
  }

  FilledButton button(WidgetTester tester, String key) =>
      tester.widget<FilledButton>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(FilledButton),
        ),
      );

  testWidgets('nominated list shows the cards and assumes a case', (
    tester,
  ) async {
    final repository = FakeCareRepository(
      nominatedCases: [
        careCase(id: 1),
        careCase(id: 2, fullName: 'João Lima', urgency: Urgency.low),
      ],
    );

    await pump(
      tester,
      CareListPage(
        mode: CareListMode.nominated,
        store: CareListStore(repository),
        token: 'jwt',
      ),
    );

    expect(find.text('Maria Souza'), findsOneWidget);
    expect(find.text('João Lima'), findsOneWidget);
    expect(find.text('Região: Centro'), findsNWidgets(2));
    expect(find.text('Distância aproximada: 2,4 km'), findsNWidgets(2));
    expect(find.text('Necessidades: Alimentação'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('care_assume_1')));
    await tester.pumpAndSettle();

    expect(repository.assumed, [1]);
    expect(find.text('Maria Souza'), findsNothing);
    expect(
      find.text('Você assumiu o atendimento de Maria Souza.'),
      findsOneWidget,
    );
  });

  testWidgets('in care list shows who is responsible and stale updates', (
    tester,
  ) async {
    final repository = FakeCareRepository(
      myCaseList: [
        careCase(
          status: CareStatus.inCare,
          organizationName: 'Amigos dos Rios',
          careUpdatedAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ],
    );

    await pump(
      tester,
      CareListPage(
        mode: CareListMode.myCases,
        store: CareListStore(repository),
        token: 'jwt',
      ),
    );

    expect(find.text('Responsável: Amigos dos Rios'), findsOneWidget);
    expect(find.text('Início: 02/09/2026'), findsOneWidget);
    expect(find.text('4 dias sem atualização'), findsOneWidget);
    expect(find.text('Ver caso'), findsOneWidget);
  });

  testWidgets('a nominated case can be assumed from its detail page', (
    tester,
  ) async {
    final repository = FakeCareRepository(
      details: {1: CareCaseDetail(person: careCase(), records: const [])},
    );

    await pump(
      tester,
      CareCasePage(personId: 1, store: CareCaseStore(repository), token: 'jwt'),
    );

    expect(find.text('Maria Souza'), findsOneWidget);
    expect(find.text('Necessidades'), findsOneWidget);
    expect(find.text('•  Dorme na praça'), findsOneWidget);
    expect(find.text('Histórico'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const Key('care_case_assume_button')),
    );
    await tester.tap(find.byKey(const Key('care_case_assume_button')));
    await tester.pumpAndSettle();

    expect(repository.assumed, [1]);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Adicionar Andamento'), findsOneWidget);
  });

  testWidgets('a case in care shows referrals and the history', (tester) async {
    final repository = FakeCareRepository(
      details: {
        1: CareCaseDetail(
          person: careCase(
            status: CareStatus.inCare,
            organizationName: 'Amigos dos Rios',
          ),
          records: [
            careRecord(referral: 'CRAS Centro'),
            careRecord(number: 2, status: CareRecordStatus.inProgress),
          ],
        ),
      },
    );

    await pump(
      tester,
      CareCasePage(personId: 1, store: CareCaseStore(repository), token: 'jwt'),
    );

    expect(find.text('Encaminhamentos'), findsOneWidget);
    expect(find.text('•  CRAS Centro'), findsOneWidget);
    expect(find.text('Andamento #1'), findsOneWidget);
    expect(find.text('Andamento #2'), findsOneWidget);
    expect(find.text('Adicionar Andamento'), findsOneWidget);
  });

  testWidgets('finishing a case asks for the reason before saving', (
    tester,
  ) async {
    final detail = CareCaseDetail(
      person: careCase(status: CareStatus.inCare),
      records: [careRecord()],
    );
    final repository = FakeCareRepository(details: {1: detail});
    final store = CareRecordFormStore(repository);

    await pump(
      tester,
      CareRecordFormPage(
        detail: detail,
        store: store,
        tagsStore: seededTagsStore(),
        token: 'jwt',
      ),
    );

    expect(find.text('Andamento #2'), findsOneWidget);
    expect(find.text('Em atendimento'), findsOneWidget);
    expect(find.text('Moradia'), findsOneWidget);
    expect(button(tester, 'care_record_submit_button').onPressed, isNotNull);

    await tester.tap(find.text('Finalizado'));
    await tester.pumpAndSettle();

    expect(find.text('Motivo da finalização'), findsOneWidget);
    expect(find.text('Finalizar atendimento'), findsOneWidget);
    expect(button(tester, 'care_record_submit_button').onPressed, isNull);

    store.setFinishReason(FinishReason.helped);
    await tester.pumpAndSettle();

    expect(button(tester, 'care_record_submit_button').onPressed, isNotNull);
  });
}
