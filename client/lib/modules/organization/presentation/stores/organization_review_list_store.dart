import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';

part 'organization_review_list_store.g.dart';

class OrganizationReviewListStore = OrganizationReviewListStoreBase
    with _$OrganizationReviewListStore;

abstract class OrganizationReviewListStoreBase with Store {
  OrganizationReviewListStoreBase(this._repository);

  final OrganizationRepository _repository;

  @observable
  OrganizationStatus? filter;

  @observable
  String search = '';

  @observable
  List<Organization> organizations = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  void setSearch(String value) => search = value;

  @action
  Future<void> setFilter(OrganizationStatus? value, String token) {
    filter = value;
    return load(token);
  }

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      organizations = await _repository.list(
        token,
        status: filter,
        search: search,
      );
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar as validações.';
    } finally {
      isLoading = false;
    }
  }
}
