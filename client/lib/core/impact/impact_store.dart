import 'package:mobx/mobx.dart';

import 'impact_repository.dart';

part 'impact_store.g.dart';

class ImpactStore = ImpactStoreBase with _$ImpactStore;

abstract class ImpactStoreBase with Store {
  ImpactStoreBase(this._repository);

  final ImpactRepository _repository;

  @observable
  PlatformImpact? platform;

  @observable
  OrganizationImpact? organization;

  @action
  Future<void> loadPlatform(String token) async {
    try {
      platform = await _repository.platform(token);
    } catch (_) {}
  }

  @action
  Future<void> loadOrganization(String token) async {
    try {
      organization = await _repository.organization(token);
    } catch (_) {}
  }
}
