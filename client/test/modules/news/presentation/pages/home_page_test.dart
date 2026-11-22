import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/action_stores.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/campaign_stores.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_category.dart';
import 'package:ajuda_bem/modules/news/presentation/pages/home_page.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_store.dart';
import 'package:ajuda_bem/modules/profile/presentation/stores/profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../initiatives/initiative_test_doubles.dart';
import '../../news_test_doubles.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester, {String? token}) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomePage(
          store: NewsStore(FakeNewsRepository()),
          profileStore: ProfileStore(FakeProfileRepository(role: 'USER')),
          campaignsStore: CampaignsFeedStore(
            FakeCampaignRepository(
              campaigns: [campaignWith(id: 7, title: 'Inverno Solidário')],
            ),
          ),
          actionsStore: OpenActionsStore(
            FakeActionRepository(actions: [actionWith(id: 3)]),
          ),
          authToken: token,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a signed-in user gets the greeting, shortcuts and sections', (
    tester,
  ) async {
    await pumpHome(tester, token: 'jwt-token');

    expect(find.text('Olá, Test!'), findsOneWidget);
    expect(find.byKey(const Key('home_welcome_card')), findsNothing);
    expect(find.text('Indicar pessoa'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('home_shortcut_help_points')),
        matching: find.text('Pontos de ajuda'),
      ),
      findsOneWidget,
    );
    expect(find.text('Ser voluntário'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);

    expect(find.text('Ações voluntárias'), findsOneWidget);
    expect(find.text('Distribuição de alimentos'), findsOneWidget);
    expect(find.text('Novidades'), findsOneWidget);
    expect(find.byKey(const Key('news_featured_1')), findsOneWidget);
    expect(find.byKey(const Key('home_campaign_7')), findsOneWidget);
    expect(find.text('Ver todas'), findsNWidgets(2));

    await tester.ensureVisible(
      find.byKey(const Key('news_category_campaigns')),
    );
    await tester.tap(find.byKey(const Key('news_category_campaigns')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_campaign_7')), findsOneWidget);
    expect(find.text('Inverno Solidário'), findsOneWidget);
    expect(find.byKey(const Key('news_card_2')), findsNothing);
  });

  testWidgets('a visitor gets the welcome card and locked shortcuts', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.byKey(const Key('home_welcome_card')), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.textContaining('Olá'), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));

    expect(find.text('Ações voluntárias'), findsNothing);
    expect(find.byKey(const Key('news_category_campaigns')), findsOneWidget);
    expect(find.byKey(const Key('news_featured_1')), findsOneWidget);
  });

  testWidgets('the category chips filter the news strip', (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomePage(
          store: NewsStore(
            FakeNewsRepository(
              articles: [
                articleWith(id: 1, title: 'Destaque da semana'),
                articleWith(
                  id: 2,
                  title: 'Vacinação no bairro',
                  category: NewsCategory.health,
                ),
                articleWith(
                  id: 3,
                  title: 'Aulas de reforço',
                  category: NewsCategory.education,
                ),
              ],
            ),
          ),
          profileStore: ProfileStore(FakeProfileRepository(role: 'USER')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('news_featured_1')), findsOneWidget);
    expect(find.byKey(const Key('news_card_2')), findsOneWidget);
    expect(find.byKey(const Key('news_card_3')), findsOneWidget);

    await tester.tap(find.byKey(const Key('news_category_HEALTH')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('news_card_2')), findsOneWidget);
    expect(find.byKey(const Key('news_card_3')), findsNothing);
  });
}
