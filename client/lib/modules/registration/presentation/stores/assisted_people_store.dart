import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/assisted_person.dart';
import '../../domain/repositories/assisted_person_repository.dart';

part 'assisted_people_store.g.dart';

class AssistedPeopleStore = AssistedPeopleStoreBase with _$AssistedPeopleStore;

abstract class AssistedPeopleStoreBase with Store {
  AssistedPeopleStoreBase(this._repository);

  final AssistedPersonRepository _repository;

  @observable
  List<AssistedPerson> people = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  Set<int> deletingIds = {};

  @action
  Future<void> load(String token) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      people = await _repository.getAll(token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar os cadastros.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> deletePerson(int id, String token) async {
    deletingIds = {...deletingIds, id};
    errorMessage = null;

    try {
      await _repository.delete(id, token);
      people = people.where((person) => person.id != id).toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível excluir o cadastro.';
      return false;
    } finally {
      deletingIds = Set<int>.from(deletingIds)..remove(id);
    }
  }

  bool isDeleting(int id) => deletingIds.contains(id);
}
