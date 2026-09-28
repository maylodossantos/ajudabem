import 'package:mobx/mobx.dart';

import '../errors/app_exception.dart';
import 'need_tag.dart';
import 'tags_repository.dart';

part 'tags_store.g.dart';

class TagsStore = TagsStoreBase with _$TagsStore;

abstract class TagsStoreBase with Store {
  TagsStoreBase(this._repository);

  final TagsRepository _repository;

  @observable
  List<NeedTag> tags = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isSaving = false;

  List<int> idsOf(Iterable<String> names) => [
    for (final tag in tags)
      if (names.contains(tag.name)) tag.id,
  ];

  @action
  Future<void> ensureLoaded(String token) async {
    if (tags.isEmpty && !isLoading) {
      await load(token);
    }
  }

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      tags = await _repository.getAll(token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar as necessidades.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> save(String name, String token, {int? id}) => _change(() async {
    final saved = id == null
        ? await _repository.create(name.trim(), token)
        : await _repository.update(id, name.trim(), token);
    tags = id == null
        ? [...tags, saved]
        : [for (final tag in tags) tag.id == id ? saved : tag];
  });

  @action
  Future<bool> delete(int id, String token) => _change(() async {
    await _repository.delete(id, token);
    tags = tags.where((tag) => tag.id != id).toList();
  });

  @action
  Future<bool> _change(Future<void> Function() change) async {
    isSaving = true;
    errorMessage = null;

    try {
      await change();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível salvar a necessidade.';
      return false;
    } finally {
      isSaving = false;
    }
  }
}
