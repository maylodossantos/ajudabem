import 'package:ajuda_bem/core/tags/need_tag.dart';
import 'package:ajuda_bem/core/tags/tags_repository.dart';
import 'package:ajuda_bem/core/tags/tags_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const seededTags = [
  NeedTag(id: 1, name: 'Alimentação'),
  NeedTag(id: 2, name: 'Moradia'),
  NeedTag(id: 3, name: 'Saúde'),
  NeedTag(id: 4, name: 'Apoio emocional'),
  NeedTag(id: 5, name: 'Reabilitação'),
  NeedTag(id: 6, name: 'Roupas'),
];

TagsStore seededTagsStore() {
  final store = TagsStore(
    TagsRepository(MockClient((_) async => http.Response('[]', 200))),
  );
  store.tags = List.of(seededTags);
  return store;
}
