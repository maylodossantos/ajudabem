// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OrganizationFormStore on OrganizationFormStoreBase, Store {
  Computed<bool>? _$canContinueComputed;

  @override
  bool get canContinue => (_$canContinueComputed ??= Computed<bool>(
    () => super.canContinue,
    name: 'OrganizationFormStoreBase.canContinue',
  )).value;
  Computed<bool>? _$allDocumentsSentComputed;

  @override
  bool get allDocumentsSent => (_$allDocumentsSentComputed ??= Computed<bool>(
    () => super.allDocumentsSent,
    name: 'OrganizationFormStoreBase.allDocumentsSent',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'OrganizationFormStoreBase.canSubmit',
  )).value;

  late final _$pickedDocumentsAtom = Atom(
    name: 'OrganizationFormStoreBase.pickedDocuments',
    context: context,
  );

  @override
  ObservableMap<OrganizationDocumentType, SelectedFile> get pickedDocuments {
    _$pickedDocumentsAtom.reportRead();
    return super.pickedDocuments;
  }

  @override
  set pickedDocuments(
    ObservableMap<OrganizationDocumentType, SelectedFile> value,
  ) {
    _$pickedDocumentsAtom.reportWrite(value, super.pickedDocuments, () {
      super.pickedDocuments = value;
    });
  }

  late final _$sentDocumentsAtom = Atom(
    name: 'OrganizationFormStoreBase.sentDocuments',
    context: context,
  );

  @override
  Map<OrganizationDocumentType, OrganizationDocument> get sentDocuments {
    _$sentDocumentsAtom.reportRead();
    return super.sentDocuments;
  }

  @override
  set sentDocuments(Map<OrganizationDocumentType, OrganizationDocument> value) {
    _$sentDocumentsAtom.reportWrite(value, super.sentDocuments, () {
      super.sentDocuments = value;
    });
  }

  late final _$stepAtom = Atom(
    name: 'OrganizationFormStoreBase.step',
    context: context,
  );

  @override
  int get step {
    _$stepAtom.reportRead();
    return super.step;
  }

  @override
  set step(int value) {
    _$stepAtom.reportWrite(value, super.step, () {
      super.step = value;
    });
  }

  late final _$corporateNameAtom = Atom(
    name: 'OrganizationFormStoreBase.corporateName',
    context: context,
  );

  @override
  String get corporateName {
    _$corporateNameAtom.reportRead();
    return super.corporateName;
  }

  @override
  set corporateName(String value) {
    _$corporateNameAtom.reportWrite(value, super.corporateName, () {
      super.corporateName = value;
    });
  }

  late final _$tradeNameAtom = Atom(
    name: 'OrganizationFormStoreBase.tradeName',
    context: context,
  );

  @override
  String get tradeName {
    _$tradeNameAtom.reportRead();
    return super.tradeName;
  }

  @override
  set tradeName(String value) {
    _$tradeNameAtom.reportWrite(value, super.tradeName, () {
      super.tradeName = value;
    });
  }

  late final _$cnpjAtom = Atom(
    name: 'OrganizationFormStoreBase.cnpj',
    context: context,
  );

  @override
  String get cnpj {
    _$cnpjAtom.reportRead();
    return super.cnpj;
  }

  @override
  set cnpj(String value) {
    _$cnpjAtom.reportWrite(value, super.cnpj, () {
      super.cnpj = value;
    });
  }

  late final _$activityAreaAtom = Atom(
    name: 'OrganizationFormStoreBase.activityArea',
    context: context,
  );

  @override
  String? get activityArea {
    _$activityAreaAtom.reportRead();
    return super.activityArea;
  }

  @override
  set activityArea(String? value) {
    _$activityAreaAtom.reportWrite(value, super.activityArea, () {
      super.activityArea = value;
    });
  }

  late final _$streetAtom = Atom(
    name: 'OrganizationFormStoreBase.street',
    context: context,
  );

  @override
  String get street {
    _$streetAtom.reportRead();
    return super.street;
  }

  @override
  set street(String value) {
    _$streetAtom.reportWrite(value, super.street, () {
      super.street = value;
    });
  }

  late final _$numberAtom = Atom(
    name: 'OrganizationFormStoreBase.number',
    context: context,
  );

  @override
  String get number {
    _$numberAtom.reportRead();
    return super.number;
  }

  @override
  set number(String value) {
    _$numberAtom.reportWrite(value, super.number, () {
      super.number = value;
    });
  }

  late final _$neighborhoodAtom = Atom(
    name: 'OrganizationFormStoreBase.neighborhood',
    context: context,
  );

  @override
  String get neighborhood {
    _$neighborhoodAtom.reportRead();
    return super.neighborhood;
  }

  @override
  set neighborhood(String value) {
    _$neighborhoodAtom.reportWrite(value, super.neighborhood, () {
      super.neighborhood = value;
    });
  }

  late final _$cityAtom = Atom(
    name: 'OrganizationFormStoreBase.city',
    context: context,
  );

  @override
  String get city {
    _$cityAtom.reportRead();
    return super.city;
  }

  @override
  set city(String value) {
    _$cityAtom.reportWrite(value, super.city, () {
      super.city = value;
    });
  }

  late final _$stateAtom = Atom(
    name: 'OrganizationFormStoreBase.state',
    context: context,
  );

  @override
  String? get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(String? value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$zipCodeAtom = Atom(
    name: 'OrganizationFormStoreBase.zipCode',
    context: context,
  );

  @override
  String get zipCode {
    _$zipCodeAtom.reportRead();
    return super.zipCode;
  }

  @override
  set zipCode(String value) {
    _$zipCodeAtom.reportWrite(value, super.zipCode, () {
      super.zipCode = value;
    });
  }

  late final _$websiteAtom = Atom(
    name: 'OrganizationFormStoreBase.website',
    context: context,
  );

  @override
  String get website {
    _$websiteAtom.reportRead();
    return super.website;
  }

  @override
  set website(String value) {
    _$websiteAtom.reportWrite(value, super.website, () {
      super.website = value;
    });
  }

  late final _$instagramAtom = Atom(
    name: 'OrganizationFormStoreBase.instagram',
    context: context,
  );

  @override
  String get instagram {
    _$instagramAtom.reportRead();
    return super.instagram;
  }

  @override
  set instagram(String value) {
    _$instagramAtom.reportWrite(value, super.instagram, () {
      super.instagram = value;
    });
  }

  late final _$acceptedTermsAtom = Atom(
    name: 'OrganizationFormStoreBase.acceptedTerms',
    context: context,
  );

  @override
  bool get acceptedTerms {
    _$acceptedTermsAtom.reportRead();
    return super.acceptedTerms;
  }

  @override
  set acceptedTerms(bool value) {
    _$acceptedTermsAtom.reportWrite(value, super.acceptedTerms, () {
      super.acceptedTerms = value;
    });
  }

  late final _$acceptedDataProcessingAtom = Atom(
    name: 'OrganizationFormStoreBase.acceptedDataProcessing',
    context: context,
  );

  @override
  bool get acceptedDataProcessing {
    _$acceptedDataProcessingAtom.reportRead();
    return super.acceptedDataProcessing;
  }

  @override
  set acceptedDataProcessing(bool value) {
    _$acceptedDataProcessingAtom.reportWrite(
      value,
      super.acceptedDataProcessing,
      () {
        super.acceptedDataProcessing = value;
      },
    );
  }

  late final _$declaredTruthfulAtom = Atom(
    name: 'OrganizationFormStoreBase.declaredTruthful',
    context: context,
  );

  @override
  bool get declaredTruthful {
    _$declaredTruthfulAtom.reportRead();
    return super.declaredTruthful;
  }

  @override
  set declaredTruthful(bool value) {
    _$declaredTruthfulAtom.reportWrite(value, super.declaredTruthful, () {
      super.declaredTruthful = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'OrganizationFormStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'OrganizationFormStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$pickDocumentAsyncAction = AsyncAction(
    'OrganizationFormStoreBase.pickDocument',
    context: context,
  );

  @override
  Future<String?> pickDocument(OrganizationDocumentType type) {
    return _$pickDocumentAsyncAction.run(() => super.pickDocument(type));
  }

  late final _$submitAsyncAction = AsyncAction(
    'OrganizationFormStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit(String token) {
    return _$submitAsyncAction.run(() => super.submit(token));
  }

  late final _$OrganizationFormStoreBaseActionController = ActionController(
    name: 'OrganizationFormStoreBase',
    context: context,
  );

  @override
  void populate(Organization organization) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.populate');
    try {
      return super.populate(organization);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCorporateName(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setCorporateName');
    try {
      return super.setCorporateName(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTradeName(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setTradeName');
    try {
      return super.setTradeName(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCnpj(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setCnpj');
    try {
      return super.setCnpj(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setActivityArea(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setActivityArea');
    try {
      return super.setActivityArea(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStreet(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setStreet');
    try {
      return super.setStreet(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNumber(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setNumber');
    try {
      return super.setNumber(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNeighborhood(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setNeighborhood');
    try {
      return super.setNeighborhood(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCity(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setCity');
    try {
      return super.setCity(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setState(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setState');
    try {
      return super.setState(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setZipCode(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setZipCode');
    try {
      return super.setZipCode(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWebsite(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setWebsite');
    try {
      return super.setWebsite(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInstagram(String value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setInstagram');
    try {
      return super.setInstagram(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAcceptedTerms(bool value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setAcceptedTerms');
    try {
      return super.setAcceptedTerms(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAcceptedDataProcessing(bool value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(
          name: 'OrganizationFormStoreBase.setAcceptedDataProcessing',
        );
    try {
      return super.setAcceptedDataProcessing(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDeclaredTruthful(bool value) {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.setDeclaredTruthful');
    try {
      return super.setDeclaredTruthful(value);
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void goToDocuments() {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.goToDocuments');
    try {
      return super.goToDocuments();
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void backToData() {
    final _$actionInfo = _$OrganizationFormStoreBaseActionController
        .startAction(name: 'OrganizationFormStoreBase.backToData');
    try {
      return super.backToData();
    } finally {
      _$OrganizationFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pickedDocuments: ${pickedDocuments},
sentDocuments: ${sentDocuments},
step: ${step},
corporateName: ${corporateName},
tradeName: ${tradeName},
cnpj: ${cnpj},
activityArea: ${activityArea},
street: ${street},
number: ${number},
neighborhood: ${neighborhood},
city: ${city},
state: ${state},
zipCode: ${zipCode},
website: ${website},
instagram: ${instagram},
acceptedTerms: ${acceptedTerms},
acceptedDataProcessing: ${acceptedDataProcessing},
declaredTruthful: ${declaredTruthful},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
canContinue: ${canContinue},
allDocumentsSent: ${allDocumentsSent},
canSubmit: ${canSubmit}
    ''';
  }
}
