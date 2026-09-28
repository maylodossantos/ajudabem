import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/entities/care_filter.dart';
import '../../domain/repositories/care_repository.dart';

part 'care_list_store.g.dart';

enum CareListMode { nominated, myCases }

class CareListStore = CareListStoreBase with _$CareListStore;

abstract class CareListStoreBase with Store {
  CareListStoreBase(this._repository);

  final CareRepository _repository;

  @observable
  CareListMode mode = CareListMode.nominated;

  @observable
  List<CareCase> cases = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  CareFilter filter = const CareFilter();

  @observable
  Set<int> assumingIds = {};

  @computed
  List<CareCase> get visibleCases => filter.apply(cases);

  @computed
  CareOptions get options => CareOptions.from(cases);

  bool isAssuming(int id) => assumingIds.contains(id);

  @action
  Future<void> load(String token, {CareListMode? mode}) async {
    if (mode != null) this.mode = mode;
    isLoading = true;
    errorMessage = null;

    try {
      cases = this.mode == CareListMode.nominated
          ? await _repository.nominated(token)
          : await _repository.myCases(token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar os casos.';
    } finally {
      isLoading = false;
    }
  }

  @action
  void setSearch(String value) => filter = filter.copyWith(search: value);

  @action
  void applyFilter(CareFilter value) =>
      filter = value.copyWith(search: filter.search);

  @action
  Future<bool> assume(int id, String token) async {
    assumingIds = {...assumingIds, id};
    errorMessage = null;

    try {
      await _repository.assume(id, token);
      cases = cases.where((person) => person.id != id).toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível assumir o atendimento.';
      return false;
    } finally {
      assumingIds = Set.of(assumingIds)..remove(id);
    }
  }
}
