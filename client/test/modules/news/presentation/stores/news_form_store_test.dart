import 'dart:typed_data';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_article.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_form_params.dart';
import 'package:ajuda_bem/modules/news/domain/repositories/news_repository.dart';
import 'package:ajuda_bem/modules/news/presentation/stores/news_form_store.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewsFormStore', () {
    test('starts in create mode with submit disabled', () {
      final store = _store();

      expect(store.isEditing, isFalse);
      expect(store.canSubmit, isFalse);
    });

    test('populate switches to edit mode and prefills the form', () {
      final store = _store();

      store.populate(
        const NewsArticle(
          id: 9,
          title: 'Campanha do inverno',
          subtitle: 'Ajude quem precisa',
          content: 'Texto completo.',
          coverImage: 'https://i.ibb.co/abc/cover.png',
          authorName: 'ONG Esperança',
        ),
      );

      expect(store.isEditing, isTrue);
      expect(store.title, 'Campanha do inverno');
      expect(store.cover.imageUrl, 'https://i.ibb.co/abc/cover.png');
      expect(store.canSubmit, isTrue);
    });

    test('cannot submit without title or content', () {
      final store = _store();
      store.setTitle('Título');

      expect(store.canSubmit, isFalse);
    });

    test('publishes the cover that was just uploaded', () async {
      final repository = _FakeNewsRepository();
      final store =
          NewsFormStore(
              repository,
              _FakeImageUploadService(url: 'https://i.ibb.co/new/cover.png'),
            )
            ..setTitle('Título')
            ..setContent('Conteúdo');

      await store.cover.upload(XFile.fromData(Uint8List(0), name: 'c.png'));
      await store.submit('jwt-token');

      expect(
        repository.createdParams?.coverImage,
        'https://i.ibb.co/new/cover.png',
      );
    });

    test('creates a new article through the repository', () async {
      final repository = _FakeNewsRepository();
      final store = NewsFormStore(repository, _FakeImageUploadService());
      store.setTitle('Título');
      store.setContent('Conteúdo');

      final success = await store.submit('jwt-token');

      expect(success, isTrue);
      expect(repository.receivedToken, 'jwt-token');
      expect(repository.createdParams?.title, 'Título');
      expect(repository.updatedId, isNull);
    });

    test('updates an existing article through the repository', () async {
      final repository = _FakeNewsRepository();
      final store = NewsFormStore(repository, _FakeImageUploadService());
      store.populate(
        const NewsArticle(
          id: 5,
          title: 'Título antigo',
          subtitle: '',
          content: 'Conteúdo antigo',
          coverImage: null,
          authorName: 'ONG Esperança',
        ),
      );
      store.setTitle('Título novo');

      final success = await store.submit('jwt-token');

      expect(success, isTrue);
      expect(repository.updatedId, 5);
      expect(repository.createdParams, isNull);
    });

    test('exposes an error message when saving fails', () async {
      final repository = _FakeNewsRepository(
        error: const AppException('Não foi possível salvar a notícia.'),
      );
      final store = NewsFormStore(repository, _FakeImageUploadService());
      store.setTitle('Título');
      store.setContent('Conteúdo');

      final success = await store.submit('jwt-token');

      expect(success, isFalse);
      expect(store.errorMessage, 'Não foi possível salvar a notícia.');
    });
  });
}

NewsFormStore _store() {
  return NewsFormStore(_FakeNewsRepository(), _FakeImageUploadService());
}

class _FakeNewsRepository implements NewsRepository {
  _FakeNewsRepository({this.error});

  final Object? error;
  String? receivedToken;
  NewsFormParams? createdParams;
  int? updatedId;

  @override
  Future<List<NewsArticle>> getAll(String? token) {
    throw UnimplementedError();
  }

  @override
  Future<NewsArticle> create(NewsFormParams params, String token) async {
    receivedToken = token;
    createdParams = params;

    if (error != null) {
      throw error!;
    }

    return NewsArticle(
      id: 1,
      title: params.title,
      subtitle: params.subtitle,
      content: params.content,
      coverImage: params.coverImage,
      authorName: 'ONG Esperança',
    );
  }

  @override
  Future<NewsArticle> update(
    int id,
    NewsFormParams params,
    String token,
  ) async {
    receivedToken = token;
    updatedId = id;

    if (error != null) {
      throw error!;
    }

    return NewsArticle(
      id: id,
      title: params.title,
      subtitle: params.subtitle,
      content: params.content,
      coverImage: params.coverImage,
      authorName: 'ONG Esperança',
    );
  }

  @override
  Future<void> delete(int id, String token) {
    throw UnimplementedError();
  }
}

class _FakeImageUploadService implements ImageUploadService {
  _FakeImageUploadService({this.url = 'https://i.ibb.co/fake/cover.png'});

  final String url;

  @override
  Future<String> uploadImage(XFile file) async {
    return url;
  }
}
