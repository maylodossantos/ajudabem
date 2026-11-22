import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/masked_input_formatter.dart';
import '../../domain/entities/organization.dart';
import '../../domain/entities/organization_contact_params.dart';
import '../../domain/repositories/organization_repository.dart';

part 'organization_contact_store.g.dart';

class OrganizationContactStore = OrganizationContactStoreBase
    with _$OrganizationContactStore;

abstract class OrganizationContactStoreBase with Store {
  OrganizationContactStoreBase(this._repository);

  final OrganizationRepository _repository;

  @observable
  String street = '';

  @observable
  String number = '';

  @observable
  String neighborhood = '';

  @observable
  String city = '';

  @observable
  String? state;

  @observable
  String zipCode = '';

  @observable
  String website = '';

  @observable
  String instagram = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get canSave =>
      street.trim().isNotEmpty &&
      number.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state != null &&
      CepInputFormatter.isComplete(zipCode) &&
      !isLoading;

  @action
  void populate(Organization organization) {
    street = organization.street;
    number = organization.number;
    neighborhood = organization.neighborhood;
    city = organization.city;
    state = organization.state.isEmpty ? null : organization.state;
    zipCode = CepInputFormatter.display(organization.zipCode);
    website = organization.website ?? '';
    instagram = organization.instagram ?? '';
  }

  @action
  void setStreet(String value) => street = value;

  @action
  void setNumber(String value) => number = value;

  @action
  void setNeighborhood(String value) => neighborhood = value;

  @action
  void setCity(String value) => city = value;

  @action
  void setState(String value) => state = value;

  @action
  void setZipCode(String value) => zipCode = value;

  @action
  void setWebsite(String value) => website = value;

  @action
  void setInstagram(String value) => instagram = value;

  @action
  Future<Organization?> save(String token) async {
    if (!canSave) {
      return null;
    }

    isLoading = true;
    errorMessage = null;

    try {
      return await _repository.updateContact(
        OrganizationContactParams(
          street: street.trim(),
          number: number.trim(),
          neighborhood: neighborhood.trim(),
          city: city.trim(),
          state: state!,
          zipCode: MaskedInputFormatter.digitsOnly(zipCode),
          website: website.trim(),
          instagram: instagram.trim(),
        ),
        token,
      );
    } on AppException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Não foi possível salvar os dados da ONG.';
      return null;
    } finally {
      isLoading = false;
    }
  }
}
