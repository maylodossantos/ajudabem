// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_contact_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OrganizationContactStore on OrganizationContactStoreBase, Store {
  Computed<bool>? _$canSaveComputed;

  @override
  bool get canSave => (_$canSaveComputed ??= Computed<bool>(
    () => super.canSave,
    name: 'OrganizationContactStoreBase.canSave',
  )).value;

  late final _$streetAtom = Atom(
    name: 'OrganizationContactStoreBase.street',
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
    name: 'OrganizationContactStoreBase.number',
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
    name: 'OrganizationContactStoreBase.neighborhood',
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
    name: 'OrganizationContactStoreBase.city',
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
    name: 'OrganizationContactStoreBase.state',
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
    name: 'OrganizationContactStoreBase.zipCode',
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
    name: 'OrganizationContactStoreBase.website',
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
    name: 'OrganizationContactStoreBase.instagram',
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

  late final _$isLoadingAtom = Atom(
    name: 'OrganizationContactStoreBase.isLoading',
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
    name: 'OrganizationContactStoreBase.errorMessage',
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

  late final _$saveAsyncAction = AsyncAction(
    'OrganizationContactStoreBase.save',
    context: context,
  );

  @override
  Future<Organization?> save(String token) {
    return _$saveAsyncAction.run(() => super.save(token));
  }

  late final _$OrganizationContactStoreBaseActionController = ActionController(
    name: 'OrganizationContactStoreBase',
    context: context,
  );

  @override
  void populate(Organization organization) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.populate');
    try {
      return super.populate(organization);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStreet(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setStreet');
    try {
      return super.setStreet(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNumber(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setNumber');
    try {
      return super.setNumber(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNeighborhood(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setNeighborhood');
    try {
      return super.setNeighborhood(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCity(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setCity');
    try {
      return super.setCity(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setState(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setState');
    try {
      return super.setState(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setZipCode(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setZipCode');
    try {
      return super.setZipCode(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWebsite(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setWebsite');
    try {
      return super.setWebsite(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInstagram(String value) {
    final _$actionInfo = _$OrganizationContactStoreBaseActionController
        .startAction(name: 'OrganizationContactStoreBase.setInstagram');
    try {
      return super.setInstagram(value);
    } finally {
      _$OrganizationContactStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
street: ${street},
number: ${number},
neighborhood: ${neighborhood},
city: ${city},
state: ${state},
zipCode: ${zipCode},
website: ${website},
instagram: ${instagram},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
canSave: ${canSave}
    ''';
  }
}
