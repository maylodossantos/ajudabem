import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/volunteer_action.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/pages/action_detail_page.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/pages/action_volunteers_page.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/pages/campaign_detail_page.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/pages/initiatives_page.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/pages/volunteer_actions_page.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/action_stores.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/campaign_stores.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/initiatives_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../initiative_test_doubles.dart';

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
          matchRoot: true,
        ),
      );

  testWidgets('an ONG without initiatives sees the empty state', (
    tester,
  ) async {
    await pump(
      tester,
      InitiativesPage(
        store: InitiativesStore(
          FakeCampaignRepository(),
          FakeActionRepository(),
        ),
        token: 'jwt',
      ),
    );

    expect(find.text('Nenhuma iniciativa criada ainda'), findsOneWidget);
    expect(find.byKey(const Key('initiatives_create_fab')), findsOneWidget);
  });

  testWidgets('the ONG switches between campaigns and actions', (tester) async {
    await pump(
      tester,
      InitiativesPage(
        store: InitiativesStore(
          FakeCampaignRepository(campaigns: [campaignWith()]),
          FakeActionRepository(actions: [actionWith()]),
        ),
        token: 'jwt',
      ),
    );

    expect(find.text('Cestas Básicas'), findsOneWidget);
    expect(find.text('Sem prazo definido.'), findsOneWidget);
    expect(find.text('Criar campanha'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab_Ações')));
    await tester.pumpAndSettle();

    expect(find.text('Distribuição de alimentos'), findsOneWidget);
    expect(find.text('Data: Sábado, 21 de março.'), findsOneWidget);
    expect(find.text('Criar Ação'), findsOneWidget);
  });

  testWidgets('a volunteer applies and can cancel before being accepted', (
    tester,
  ) async {
    final repository = FakeActionRepository(actions: [actionWith(id: 4)]);

    await pump(
      tester,
      ActionDetailPage(
        args: const InitiativeArgs(4),
        store: ActionDetailStore(repository),
        token: 'jwt',
        links: FakeLinks(),
      ),
    );

    expect(find.text('3 de 6 vagas'), findsOneWidget);
    expect(find.text('•  Organizar marmitas'), findsOneWidget);
    expect(find.byKey(const Key('action_contact_whatsapp')), findsNothing);

    await tester.tap(find.text('Candidatar'));
    await tester.pumpAndSettle();
    expect(repository.calls, ['apply']);
    expect(find.text('Cancelar candidatura'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar candidatura'));
    await tester.pumpAndSettle();
    expect(repository.calls, ['apply', 'withdraw']);
    expect(find.text('Candidatar'), findsOneWidget);
  });

  testWidgets('an accepted volunteer can talk to the ONG', (tester) async {
    final links = FakeLinks();

    await pump(
      tester,
      ActionDetailPage(
        args: const InitiativeArgs(4),
        store: ActionDetailStore(
          FakeActionRepository(
            actions: [
              actionWith(
                id: 4,
                application: ApplicationStatus.accepted,
                phone: '45999990000',
                email: 'ong@example.com',
              ),
            ],
          ),
        ),
        token: 'jwt',
        links: links,
      ),
    );

    expect(find.text('Desistir'), findsOneWidget);
    await tester.tap(find.byKey(const Key('action_contact_whatsapp')));
    await tester.tap(find.byKey(const Key('action_contact_email')));
    expect(links.opened, ['wa:45999990000', 'mailto:ong@example.com']);
  });

  testWidgets('the ONG manages its action with finish and edit', (
    tester,
  ) async {
    await pump(
      tester,
      ActionDetailPage(
        args: const InitiativeArgs(4, manage: true),
        store: ActionDetailStore(
          FakeActionRepository(actions: [actionWith(id: 4)]),
        ),
        token: 'jwt',
      ),
    );

    expect(find.byKey(const Key('action_finish')), findsOneWidget);
    expect(find.byKey(const Key('action_edit')), findsOneWidget);
    expect(find.text('Candidatar'), findsNothing);
  });

  testWidgets('the ONG accepts volunteers until the action is full', (
    tester,
  ) async {
    final repository = FakeActionRepository(
      actions: [actionWith(id: 4, needed: 1, accepted: 0)],
      applications: const [
        VolunteerApplication(
          id: 1,
          name: 'Maria Silva',
          status: ApplicationStatus.pending,
        ),
        VolunteerApplication(
          id: 2,
          name: 'João Lima',
          status: ApplicationStatus.pending,
        ),
      ],
    );

    await pump(
      tester,
      ActionVolunteersPage(
        actionId: 4,
        store: VolunteersStore(repository),
        token: 'jwt',
        links: FakeLinks(),
      ),
    );

    expect(find.text('0 de 1 voluntários'), findsOneWidget);
    await tester.tap(find.byKey(const Key('accept_volunteer_1')));
    await tester.pumpAndSettle();

    expect(find.text('1 de 1 voluntários'), findsOneWidget);
    expect(find.text('Aceito'), findsOneWidget);
    expect(button(tester, 'accept_volunteer_2').onPressed, isNull);
  });

  testWidgets('the volunteer list shows what the user already joined', (
    tester,
  ) async {
    await pump(
      tester,
      VolunteerActionsPage(
        store: OpenActionsStore(
          FakeActionRepository(
            actions: [
              actionWith(id: 1, application: ApplicationStatus.accepted),
              actionWith(id: 2, title: 'Mutirão', accepted: 6),
              actionWith(id: 3, title: 'Sopão'),
            ],
          ),
        ),
        token: 'jwt',
      ),
    );

    expect(find.text('Participando'), findsOneWidget);
    expect(find.text('Vagas esgotadas'), findsOneWidget);
    expect(find.text('Responsável: Projeto Mãos que Ajudam'), findsNWidgets(3));

    await tester.ensureVisible(find.byKey(const Key('action_apply_3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action_apply_3')));
    await tester.pumpAndSettle();
    expect(find.text('Aguardando'), findsOneWidget);
  });

  testWidgets('a campaign shows how to help, and its ONG can finish it', (
    tester,
  ) async {
    final repository = FakeCampaignRepository(campaigns: [campaignWith(id: 2)]);

    await pump(
      tester,
      CampaignDetailPage(
        args: const InitiativeArgs(2, manage: true),
        store: CampaignDetailStore(repository),
        token: 'jwt',
      ),
    );

    expect(find.text('Como ajudar'), findsOneWidget);
    expect(find.text('Meta: R\$ 1.000,00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('campaign_finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalizar').last);
    await tester.pumpAndSettle();

    expect(find.text('Campanha finalizada.'), findsWidgets);
    expect(find.byKey(const Key('campaign_edit')), findsNothing);
  });
}
