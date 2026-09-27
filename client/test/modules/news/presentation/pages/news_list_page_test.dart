import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_article.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_form_params.dart';
import 'package:ajuda_bem/modules/news/domain/repositories/news_repository.dart';
import 'package:ajuda_bem/modules/news/presentation/pages/news_list_page.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_store.dart';
import 'package:ajuda_bem/modules/profile/domain/entities/user_profile.dart';
import 'package:ajuda_bem/modules/profile/domain/repositories/profile_repository.dart';
import 'package:ajuda_bem/modules/profile/presentation/stores/profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'renders the published articles without the manage menu for a regular user',
    (tester) async {
      final store = NewsStore(_FakeNewsRepository());
      final profileStore = ProfileStore(_FakeProfileRepository(role: 'USER'));

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

      expect(find.text('Campanha do inverno'), findsOneWidget);
      expect(find.text('Por ONG Esperança'), findsOneWidget);
      expect(find.text('Publicar'), findsNothing);
      expect(find.byTooltip('Opções da notícia'), findsNothing);
    },
  );

  testWidgets('hides the publish tab and manage menu for an ONG', (
    tester,
  ) async {
    final store = NewsStore(_FakeNewsRepository());
    final profileStore = ProfileStore(_FakeProfileRepository(role: 'USER_ONG'));

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
    expect(find.byTooltip('Opções da notícia'), findsNothing);
  });

  testWidgets(
    'shows the publish tab and per-article manage menu for an admin',
    (tester) async {
      final store = NewsStore(_FakeNewsRepository());
      final profileStore = ProfileStore(_FakeProfileRepository(role: 'ADMIN'));

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

      expect(find.text('Publicar'), findsOneWidget);
      expect(find.byTooltip('Opções da notícia'), findsOneWidget);
    },
  );

  testWidgets('renders the published articles for an anonymous visitor', (
    tester,
  ) async {
    final store = NewsStore(_FakeNewsRepository());
    final profileStore = ProfileStore(_FakeProfileRepository(role: 'USER'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NewsListPage(store: store, profileStore: profileStore),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Campanha do inverno'), findsOneWidget);
    expect(store.errorMessage, isNull);
    expect(find.text('Publicar'), findsNothing);
  });
}

class _FakeNewsRepository implements NewsRepository {
  @override
  Future<List<NewsArticle>> getAll(String? token) async {
    return const [
      NewsArticle(
        id: 1,
        title: 'Campanha do inverno',
        subtitle: 'Ajude quem precisa',
        content: 'Texto completo.',
        coverImage: null,
        authorName: 'ONG Esperança',
      ),
    ];
  }

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

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({required this.role});

  final String role;

  @override
  Future<UserProfile> getCurrentUser(String token) async {
    return UserProfile(
      id: 1,
      name: 'Test User',
      email: 'test@ajudabem.com',
      phone: '',
      role: role,
    );
  }

  @override
  Future<UserProfile> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount(String token) {
    throw UnimplementedError();
  }
}
