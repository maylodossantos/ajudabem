import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/cnpj_input_formatter.dart';
import '../../../../core/formatters/masked_input_formatter.dart';
import '../../../../core/files/selected_file.dart';
import '../../../../core/services/document_picker_service.dart';
import '../../domain/entities/organization.dart';
import '../../domain/entities/organization_form_params.dart';
import '../../domain/repositories/organization_repository.dart';

part 'organization_form_store.g.dart';

class OrganizationFormStore = OrganizationFormStoreBase
    with _$OrganizationFormStore;

abstract class OrganizationFormStoreBase with Store {
  OrganizationFormStoreBase(this._repository, this._documentPicker);

  final OrganizationRepository _repository;
  final DocumentPickerService _documentPicker;

  static const maxDocumentBytes = 10 * 1024 * 1024;

  @observable
  ObservableMap<OrganizationDocumentType, SelectedFile> pickedDocuments =
      ObservableMap();

  @observable
  Map<OrganizationDocumentType, OrganizationDocument> sentDocuments = {};

  static const dataStep = 0;
  static const documentsStep = 1;

  @observable
  int step = dataStep;

  @observable
  String corporateName = '';

  @observable
  String tradeName = '';

  @observable
  String cnpj = '';

  @observable
  String? activityArea;

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
  bool acceptedTerms = false;

  @observable
  bool acceptedDataProcessing = false;

  @observable
  bool declaredTruthful = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get canContinue =>
      corporateName.trim().isNotEmpty &&
      tradeName.trim().isNotEmpty &&
      CnpjInputFormatter.isComplete(cnpj) &&
      activityArea != null &&
      street.trim().isNotEmpty &&
      number.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state != null &&
      CepInputFormatter.isComplete(zipCode);

  @computed
  bool get allDocumentsSent => OrganizationDocumentType.values.every(
    (type) =>
        pickedDocuments.containsKey(type) || sentDocuments.containsKey(type),
  );

  @computed
  bool get canSubmit =>
      canContinue &&
      allDocumentsSent &&
      acceptedTerms &&
      acceptedDataProcessing &&
      declaredTruthful &&
      !isLoading;

  @action
  void populate(Organization organization) {
    corporateName = organization.corporateName;
    tradeName = organization.tradeName;
    cnpj = CnpjInputFormatter.display(organization.cnpj);
    activityArea = ActivityAreas.all.contains(organization.activityArea)
        ? organization.activityArea
        : null;
    street = organization.street;
    number = organization.number;
    neighborhood = organization.neighborhood;
    city = organization.city;
    state = organization.state.isEmpty ? null : organization.state;
    zipCode = CepInputFormatter.display(organization.zipCode);
    website = organization.website ?? '';
    instagram = organization.instagram ?? '';
    sentDocuments = {
      for (final document in organization.documents) document.type: document,
    };
    pickedDocuments.clear();
  }

  @action
  Future<String?> pickDocument(OrganizationDocumentType type) async {
    final SelectedFile? file;
    try {
      file = await _documentPicker.pickPdf();
    } catch (_) {
      return 'Não foi possível abrir o documento.';
    }
    if (file == null) {
      return null;
    }

    if (!file.name.toLowerCase().endsWith('.pdf')) {
      return 'Selecione um arquivo PDF.';
    }
    if (file.sizeBytes > maxDocumentBytes) {
      return 'Cada documento pode ter no máximo 10 MB.';
    }

    pickedDocuments[type] = file;
    return null;
  }

  @action
  void setCorporateName(String value) => corporateName = value;

  @action
  void setTradeName(String value) => tradeName = value;

  @action
  void setCnpj(String value) => cnpj = value;

  @action
  void setActivityArea(String value) => activityArea = value;

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
  void setAcceptedTerms(bool value) => acceptedTerms = value;

  @action
  void setAcceptedDataProcessing(bool value) => acceptedDataProcessing = value;

  @action
  void setDeclaredTruthful(bool value) => declaredTruthful = value;

  @action
  void goToDocuments() {
    if (canContinue) {
      step = documentsStep;
    }
  }

  @action
  void backToData() => step = dataStep;

  @action
  Future<bool> submit(String token) async {
    if (!canSubmit) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await _repository.submit(
        OrganizationFormParams(
          corporateName: corporateName.trim(),
          tradeName: tradeName.trim(),
          cnpj: MaskedInputFormatter.digitsOnly(cnpj),
          activityArea: activityArea!,
          street: street.trim(),
          number: number.trim(),
          neighborhood: neighborhood.trim(),
          city: city.trim(),
          state: state!,
          zipCode: MaskedInputFormatter.digitsOnly(zipCode),
          website: website.trim(),
          instagram: instagram.trim(),
          documentFiles: Map.of(pickedDocuments),
          acceptedTerms: acceptedTerms,
          acceptedDataProcessing: acceptedDataProcessing,
          declaredTruthful: declaredTruthful,
        ),
        token,
      );
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível enviar a validação da ONG.';
      return false;
    } finally {
      isLoading = false;
    }
  }
}
