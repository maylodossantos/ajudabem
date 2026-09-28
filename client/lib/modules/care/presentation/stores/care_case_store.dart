import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/repositories/care_repository.dart';

part 'care_case_store.g.dart';

class CareCaseStore = CareCaseStoreBase with _$CareCaseStore;

abstract class CareCaseStoreBase with Store {
  CareCaseStoreBase(this._repository);

  final CareRepository _repository;

  @observable
  CareCaseDetail? detail;

  @observable
  bool isLoading = false;

  @observable
  bool isAssuming = false;

  @observable
  String? errorMessage;

  @action
  void show(CareCaseDetail value) => detail = value;

  @action
  Future<void> load(int personId, String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      detail = await _repository.get(personId, token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar o caso.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> assume(String token) async {
    final person = detail?.person;
    if (person == null) return false;
    isAssuming = true;
    errorMessage = null;

    try {
      await _repository.assume(person.id, token);
      detail = await _repository.get(person.id, token);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível assumir o atendimento.';
      return false;
    } finally {
      isAssuming = false;
    }
  }
}
