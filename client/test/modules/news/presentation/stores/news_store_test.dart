import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_article.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_form_params.dart';
import 'package:ajuda_bem/modules/news/domain/repositories/news_repository.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the published news articles', () async {
    final repository = _FakeNewsRepository();
    final store = NewsStore(repository);

    await store.load('jwt-token');

    expect(repository.receivedToken, 'jwt-token');
    expect(store.articles, hasLength(2));
    expect(store.articles.first.title, 'Campanha do inverno');
    expect(store.errorMessage, isNull);
    expect(store.isLoading, isFalse);
  });

  test('exposes loading errors', () async {
    final store = NewsStore(
      _FakeNewsRepository(
        error: const AppException('Não foi possível carregar as notícias.'),
      ),
    );

    await store.load('jwt-token');

    expect(store.articles, isEmpty);
    expect(store.errorMessage, 'Não foi possível carregar as notícias.');
    expect(store.isLoading, isFalse);
  });

  test('deletes an article and removes it from the list', () async {
    final repository = _FakeNewsRepository();
    final store = NewsStore(repository);
    await store.load('jwt-token');

    final deleted = await store.deleteArticle(1, 'jwt-token');

    expect(deleted, isTrue);
    expect(repository.deletedId, 1);
    expect(store.articles.map((article) => article.id), [2]);
  });

  test('exposes an error message when deletion fails', () async {
    final store = NewsStore(
      _FakeNewsRepository(
        error: const AppException('Não foi possível excluir a notícia.'),
      ),
    );

    final deleted = await store.deleteArticle(1, 'jwt-token');

    expect(deleted, isFalse);
    expect(store.errorMessage, 'Não foi possível excluir a notícia.');
    expect(store.isDeleting(1), isFalse);
  });
}

class _FakeNewsRepository implements NewsRepository {
  _FakeNewsRepository({this.error});

  final Object? error;
  String? receivedToken;
  int? deletedId;

  @override
  Future<List<NewsArticle>> getAll(String? token) async {
    receivedToken = token;

    if (error != null) {
      throw error!;
    }

    return const [
      NewsArticle(
        id: 1,
        title: 'Campanha do inverno',
        subtitle: 'Ajude quem precisa',
        content: 'Texto completo.',
        coverImage: null,
        authorName: 'ONG Esperança',
      ),
      NewsArticle(
        id: 2,
        title: 'Novo posto de doação',
        subtitle: '',
        content: 'Outro texto completo.',
        coverImage: 'https://i.ibb.co/xyz/cover.png',
        authorName: 'ONG Amigos',
      ),
    ];
  }

  @override
  Future<void> delete(int id, String token) async {
    if (error != null) {
      throw error!;
    }

    deletedId = id;
  }

  @override
  Future<NewsArticle> create(NewsFormParams params, String token) {
    throw UnimplementedError();
  }

  @override
  Future<NewsArticle> update(int id, NewsFormParams params, String token) {
    throw UnimplementedError();
  }
}
