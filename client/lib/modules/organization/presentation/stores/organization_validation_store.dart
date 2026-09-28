import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';

part 'organization_validation_store.g.dart';

class OrganizationValidationStore = OrganizationValidationStoreBase
    with _$OrganizationValidationStore;

abstract class OrganizationValidationStoreBase with Store {
  OrganizationValidationStoreBase(this._repository);

  final OrganizationRepository _repository;

  @observable
  Organization? organization;

  @observable
  bool hasLoaded = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      organization = await _repository.getMine(token);
      hasLoaded = true;
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar a validação da sua ONG.';
    } finally {
      isLoading = false;
    }
  }
}
