import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/campaign_stores.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_category.dart';
import 'package:ajuda_bem/modules/news/presentation/pages/news_list_page.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_store.dart';
import 'package:ajuda_bem/modules/profile/presentation/stores/profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../initiatives/initiative_test_doubles.dart';
import '../../news_test_doubles.dart';

void main() {
  testWidgets(
    'renders the published articles without the manage menu for a regular user',
    (tester) async {
      final store = NewsStore(FakeNewsRepository());
      final profileStore = ProfileStore(FakeProfileRepository(role: 'USER'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: NewsListPage(
            store: store,
            profileStore: profileStore,
            authToken: 'jwt-token',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('news_card_1')), findsOneWidget);
      expect(find.text('Cascavel, PR'), findsOneWidget);
      expect(find.text('Publicar'), findsNothing);
      expect(find.byTooltip('Editar notícia'), findsNothing);
    },
  );

  testWidgets('hides the publish tab and manage menu for an ONG', (
    tester,
  ) async {
    final store = NewsStore(FakeNewsRepository());
    final profileStore = ProfileStore(FakeProfileRepository(role: 'USER_ONG'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NewsListPage(
          store: store,
          profileStore: profileStore,
          authToken: 'jwt-token',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Publicar'), findsNothing);
    expect(find.byTooltip('Editar notícia'), findsNothing);
  });

  testWidgets(
    'shows the per-article manage menu without a publish tab for an admin',
    (tester) async {
      final store = NewsStore(FakeNewsRepository());
      final profileStore = ProfileStore(FakeProfileRepository(role: 'ADMIN'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: NewsListPage(
            store: store,
            profileStore: profileStore,
            authToken: 'jwt-token',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Publicar'), findsNothing);
      expect(find.byTooltip('Editar notícia'), findsOneWidget);
    },
  );

  testWidgets('renders the published articles for an anonymous visitor', (
    tester,
  ) async {
    final store = NewsStore(FakeNewsRepository());
    final profileStore = ProfileStore(FakeProfileRepository(role: 'USER'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NewsListPage(store: store, profileStore: profileStore),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('news_card_1')), findsOneWidget);
    expect(store.errorMessage, isNull);
    expect(find.text('Publicar'), findsNothing);
  });

  testWidgets('switches between news and campaigns on the same page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NewsListPage(
          store: NewsStore(FakeNewsRepository()),
          profileStore: ProfileStore(FakeProfileRepository(role: 'USER')),
          campaignsStore: CampaignsFeedStore(
            FakeCampaignRepository(
              campaigns: [campaignWith(id: 1, title: 'Inverno Solidário')],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('news_card_1')), findsOneWidget);
    expect(find.byKey(const Key('campaign_card_1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('news_category_campaigns')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('news_card_1')), findsNothing);
    expect(find.byKey(const Key('campaign_card_1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('news_category_all')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('news_card_1')), findsOneWidget);
  });

  testWidgets('filters the news by category and has no search field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NewsListPage(
          store: NewsStore(
            FakeNewsRepository(
              articles: [
                articleWith(
                  id: 1,
                  title: 'Vacinação no bairro',
                  category: NewsCategory.health,
                ),
                articleWith(
                  id: 2,
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
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Destaques'), findsOneWidget);
    expect(find.byKey(const Key('news_highlight_1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('news_category_EDUCATION')));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('news_highlight_2')), findsOneWidget);
    expect(find.byKey(const Key('news_highlight_1')), findsNothing);
  });

  testWidgets('opens straight on the campaigns tab when asked', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NewsListPage(
          store: NewsStore(FakeNewsRepository()),
          profileStore: ProfileStore(FakeProfileRepository(role: 'USER')),
          campaignsStore: CampaignsFeedStore(
            FakeCampaignRepository(campaigns: [campaignWith(id: 1)]),
          ),
          showCampaigns: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('campaign_card_1')), findsOneWidget);
    expect(find.byKey(const Key('news_card_1')), findsNothing);
  });
}
