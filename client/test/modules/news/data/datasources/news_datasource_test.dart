import 'dart:convert';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/modules/news/data/datasources/news_datasource_impl.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_form_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('loads and maps the published news articles', () async {
    late http.Request capturedRequest;
    final datasource = NewsDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Campanha do inverno',
              'subtitle': 'Ajude quem precisa',
              'content': 'Texto completo da notícia.',
              'cover_image': 'https://i.ibb.co/abc/cover.png',
              'author': {'id': 9, 'name': 'ONG Esperança', 'email': 'a@b.com'},
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final articles = await datasource.getAll('jwt-token');

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/news'));
    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    expect(articles, hasLength(1));
    expect(articles.first.title, 'Campanha do inverno');
    expect(articles.first.authorName, 'ONG Esperança');
    expect(articles.first.coverImage, 'https://i.ibb.co/abc/cover.png');
  });

  test(
    'loads articles without an Authorization header when signed out',
    () async {
      late http.Request capturedRequest;
      final datasource = NewsDatasourceImpl(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response('[]', 200);
        }),
      );

      await datasource.getAll(null);

      expect(capturedRequest.headers.containsKey('Authorization'), isFalse);
    },
  );

  test('maps a server error to a friendly message', () async {
    final datasource = NewsDatasourceImpl(
      MockClient((_) async => http.Response('', 500)),
    );

    expect(
      () => datasource.getAll('jwt-token'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Não foi possível carregar as notícias.',
        ),
      ),
    );
  });

  test('creates a news article with the cover_image field', () async {
    late http.Request capturedRequest;
    final datasource = NewsDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 1,
            'title': 'Título',
            'subtitle': 'Subtítulo',
            'content': 'Conteúdo',
            'cover_image': 'https://i.ibb.co/abc/cover.png',
            'author': {'id': 9, 'name': 'ONG Esperança', 'email': 'a@b.com'},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final article = await datasource.create(
      const NewsFormParams(
        title: 'Título',
        subtitle: 'Subtítulo',
        content: 'Conteúdo',
        coverImage: 'https://i.ibb.co/abc/cover.png',
      ),
      'jwt-token',
    );

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/news'));
    expect(capturedRequest.method, 'POST');
    expect(jsonDecode(capturedRequest.body), {
      'title': 'Título',
      'subtitle': 'Subtítulo',
      'content': 'Conteúdo',
      'cover_image': 'https://i.ibb.co/abc/cover.png',
    });
    expect(article.title, 'Título');
  });

  test('maps a forbidden create to the backend message', () async {
    final datasource = NewsDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Only admins and ONGs can publish news'}),
          403,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    expect(
      () => datasource.create(
        const NewsFormParams(
          title: 'Título',
          subtitle: '',
          content: 'Conteúdo',
          coverImage: null,
        ),
        'jwt-token',
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Only admins and ONGs can publish news',
        ),
      ),
    );
  });

  test('updates a news article at its id', () async {
    late http.Request capturedRequest;
    final datasource = NewsDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 5,
            'title': 'Novo título',
            'subtitle': '',
            'content': 'Conteúdo',
            'cover_image': null,
            'author': {'id': 9, 'name': 'ONG Esperança', 'email': 'a@b.com'},
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final article = await datasource.update(
      5,
      const NewsFormParams(
        title: 'Novo título',
        subtitle: '',
        content: 'Conteúdo',
        coverImage: null,
      ),
      'jwt-token',
    );

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/news/5'));
    expect(capturedRequest.method, 'PUT');
    expect(article.title, 'Novo título');
  });

  test('deletes a news article at its id', () async {
    late http.Request capturedRequest;
    final datasource = NewsDatasourceImpl(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 200);
      }),
    );

    await datasource.delete(5, 'jwt-token');

    expect(capturedRequest.url, Uri.parse('${ApiConfig.baseUrl}/news/5'));
    expect(capturedRequest.method, 'DELETE');
  });
}
