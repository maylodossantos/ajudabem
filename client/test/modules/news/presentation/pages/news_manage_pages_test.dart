import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_article.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_form_params.dart';
import 'package:ajuda_bem/modules/news/domain/repositories/news_repository.dart';
import 'package:ajuda_bem/modules/news/presentation/pages/news_form_page.dart';
import 'package:ajuda_bem/modules/news/presentation/pages/news_manage_detail_page.dart';
import 'package:ajuda_bem/modules/news/presentation/pages/news_manage_page.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_form_store.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_store.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _article = NewsArticle(
  id: 7,
  title: 'ONG distribui 200 cestas básicas',
  subtitle: 'Ação foi realizada com apoio de voluntários',
  content: 'Texto completo da notícia.',
  coverImage: null,
  authorName: 'Admin',
  city: 'Cascavel',
  state: 'PR',
);

void main() {
  void useTallView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> pump(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: page));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state with the create button', (tester) async {
    useTallView(tester);
    await pump(
      tester,
      NewsManagePage(
        store: NewsStore(_FakeNewsRepository(const [])),
        token: 'jwt-token',
      ),
    );

    expect(find.text('Nenhuma notícia publicada ainda'), findsOneWidget);
    expect(find.byKey(const Key('news_manage_create_fab')), findsOneWidget);
  });

  testWidgets('lists the news with details buttons and filters them', (
    tester,
  ) async {
    useTallView(tester);
    await pump(
      tester,
      NewsManagePage(
        store: NewsStore(_FakeNewsRepository(const [_article])),
        token: 'jwt-token',
      ),
    );

    expect(find.text('ONG distribui 200 cestas básicas'), findsOneWidget);
    expect(find.text('Cascavel, PR'), findsOneWidget);
    expect(find.byKey(const Key('news_manage_open_7')), findsOneWidget);
    expect(find.byKey(const Key('news_manage_create_fab')), findsOneWidget);

    final field = find.descendant(
      of: find.byKey(const Key('news_manage_search')),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, 'enchente');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma notícia encontrada.'), findsOneWidget);
  });

  testWidgets('detail shows the sections with delete and edit actions', (
    tester,
  ) async {
    useTallView(tester);
    final repository = _FakeNewsRepository(const [_article]);
    await pump(
      tester,
      NewsManageDetailPage(
        article: _article,
        store: NewsStore(repository),
        token: 'jwt-token',
      ),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Sub-Título'), findsOneWidget);
    expect(find.text('Descrição'), findsOneWidget);
    expect(find.text('Texto completo da notícia.'), findsOneWidget);
    expect(find.byKey(const Key('news_manage_edit')), findsOneWidget);

    await tester.tap(find.byKey(const Key('news_manage_delete')));
    await tester.pumpAndSettle();

    expect(find.text('Excluir notícia?'), findsOneWidget);
    expect(find.byKey(const Key('confirm_dialog_cancel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm_dialog_cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Excluir notícia?'), findsNothing);
  });

  testWidgets('create form follows the model with a description counter', (
    tester,
  ) async {
    useTallView(tester);
    final store = NewsFormStore(
      _FakeNewsRepository(const []),
      _FakeImageUploadService(),
    );
    await pump(tester, NewsFormPage(store: store, token: 'jwt-token'));

    expect(find.text('Preencha as informações abaixo'), findsOneWidget);
    expect(find.text('Informações gerais:'), findsOneWidget);
    expect(find.text('Sub-Título'), findsOneWidget);
    expect(find.text('Descrição:'), findsOneWidget);
    expect(find.text('0/10000'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('news_form_content_field')),
        matching: find.byType(TextFormField),
      ),
      'Texto',
    );
    await tester.pump();

    expect(find.text('5/10000'), findsOneWidget);
    expect(store.content, 'Texto');
  });
}

class _FakeImageUploadService implements ImageUploadService {
  @override
  Future<String> uploadImage(XFile file) async => 'https://i.ibb.co/x.png';
}

class _FakeNewsRepository implements NewsRepository {
  _FakeNewsRepository(this.articles);

  final List<NewsArticle> articles;

  @override
  Future<List<NewsArticle>> getAll(String? token) async => articles;

  @override
  Future<NewsArticle> create(NewsFormParams params, String token) {
    throw UnimplementedError();
  }

  @override
  Future<NewsArticle> update(int id, NewsFormParams params, String token) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id, String token) async {}
}
