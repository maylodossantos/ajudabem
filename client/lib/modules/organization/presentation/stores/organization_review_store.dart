import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';

part 'organization_review_store.g.dart';

class OrganizationReviewStore = OrganizationReviewStoreBase
    with _$OrganizationReviewStore;

abstract class OrganizationReviewStoreBase with Store {
  OrganizationReviewStoreBase(this._repository);

  final OrganizationRepository _repository;

  static const dataStep = 0;
  static const documentsStep = 1;
  static const decisionStep = 2;

  @observable
  Organization? organization;

  @observable
  int step = dataStep;

  @observable
  bool isSubmitting = false;

  @observable
  String? errorMessage;

  @action
  void init(Organization value) {
    organization = value;
    step = dataStep;
    errorMessage = null;
  }

  @action
  void goTo(int value) => step = value;

  @action
  Future<bool> approve(String token) =>
      _review(() => _repository.approve(organization!.id, token));

  @action
  Future<bool> reject(RejectionReason reason, String? note, String token) =>
      _review(() => _repository.reject(organization!.id, reason, note, token));

  @action
  Future<bool> _review(Future<Organization> Function() call) async {
    if (organization == null || isSubmitting) {
      return false;
    }

    isSubmitting = true;
    errorMessage = null;

    try {
      organization = await call();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível concluir a análise.';
      return false;
    } finally {
      isSubmitting = false;
    }
  }
}
