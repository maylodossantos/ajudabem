// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vulnerable_person_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VulnerablePersonFormStore on VulnerablePersonFormStoreBase, Store {
  Computed<bool>? _$isEditingComputed;

  @override
  bool get isEditing => (_$isEditingComputed ??= Computed<bool>(
    () => super.isEditing,
    name: 'VulnerablePersonFormStoreBase.isEditing',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'VulnerablePersonFormStoreBase.canSubmit',
  )).value;

  late final _$assistedPersonIdAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.assistedPersonId',
    context: context,
  );

  @override
  int? get assistedPersonId {
    _$assistedPersonIdAtom.reportRead();
    return super.assistedPersonId;
  }

  @override
  set assistedPersonId(int? value) {
    _$assistedPersonIdAtom.reportWrite(value, super.assistedPersonId, () {
      super.assistedPersonId = value;
    });
  }

  late final _$hasPersonalInformationAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.hasPersonalInformation',
    context: context,
  );

  @override
  bool? get hasPersonalInformation {
    _$hasPersonalInformationAtom.reportRead();
    return super.hasPersonalInformation;
  }

  @override
  set hasPersonalInformation(bool? value) {
    _$hasPersonalInformationAtom.reportWrite(
      value,
      super.hasPersonalInformation,
      () {
        super.hasPersonalInformation = value;
      },
    );
  }

  late final _$hasFixedAddressAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.hasFixedAddress',
    context: context,
  );

  @override
  bool? get hasFixedAddress {
    _$hasFixedAddressAtom.reportRead();
    return super.hasFixedAddress;
  }

  @override
  set hasFixedAddress(bool? value) {
    _$hasFixedAddressAtom.reportWrite(value, super.hasFixedAddress, () {
      super.hasFixedAddress = value;
    });
  }

  late final _$nameAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.name',
    context: context,
  );

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$ageAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.age',
    context: context,
  );

  @override
  String get age {
    _$ageAtom.reportRead();
    return super.age;
  }

  @override
  set age(String value) {
    _$ageAtom.reportWrite(value, super.age, () {
      super.age = value;
    });
  }

  late final _$sexAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.sex',
    context: context,
  );

  @override
  String get sex {
    _$sexAtom.reportRead();
    return super.sex;
  }

  @override
  set sex(String value) {
    _$sexAtom.reportWrite(value, super.sex, () {
      super.sex = value;
    });
  }

  late final _$addressAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.address',
    context: context,
  );

  @override
  String get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  late final _$cityAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.city',
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
    name: 'VulnerablePersonFormStoreBase.state',
    context: context,
  );

  @override
  String get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(String value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$zipCodeAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.zipCode',
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

  late final _$numberAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.number',
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

  late final _$descriptionAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.description',
    context: context,
  );

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  late final _$selectedNeedsAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.selectedNeeds',
    context: context,
  );

  @override
  Set<String> get selectedNeeds {
    _$selectedNeedsAtom.reportRead();
    return super.selectedNeeds;
  }

  @override
  set selectedNeeds(Set<String> value) {
    _$selectedNeedsAtom.reportWrite(value, super.selectedNeeds, () {
      super.selectedNeeds = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'VulnerablePersonFormStoreBase.isLoading',
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
    name: 'VulnerablePersonFormStoreBase.errorMessage',
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

  late final _$submitAsyncAction = AsyncAction(
    'VulnerablePersonFormStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit(String token) {
    return _$submitAsyncAction.run(() => super.submit(token));
  }

  late final _$VulnerablePersonFormStoreBaseActionController = ActionController(
    name: 'VulnerablePersonFormStoreBase',
    context: context,
  );

  @override
  void setHasPersonalInformation(bool value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(
          name: 'VulnerablePersonFormStoreBase.setHasPersonalInformation',
        );
    try {
      return super.setHasPersonalInformation(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHasFixedAddress(bool value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setHasFixedAddress');
    try {
      return super.setHasFixedAddress(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setName(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setName');
    try {
      return super.setName(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAge(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setAge');
    try {
      return super.setAge(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSex(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setSex');
    try {
      return super.setSex(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAddress(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setAddress');
    try {
      return super.setAddress(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCity(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setCity');
    try {
      return super.setCity(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setState(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setState');
    try {
      return super.setState(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setZipCode(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setZipCode');
    try {
      return super.setZipCode(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNumber(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setNumber');
    try {
      return super.setNumber(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDescription(String value) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.setDescription');
    try {
      return super.setDescription(value);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleNeed(String need) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.toggleNeed');
    try {
      return super.toggleNeed(need);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void populate(AssistedPerson person) {
    final _$actionInfo = _$VulnerablePersonFormStoreBaseActionController
        .startAction(name: 'VulnerablePersonFormStoreBase.populate');
    try {
      return super.populate(person);
    } finally {
      _$VulnerablePersonFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
assistedPersonId: ${assistedPersonId},
hasPersonalInformation: ${hasPersonalInformation},
hasFixedAddress: ${hasFixedAddress},
name: ${name},
age: ${age},
sex: ${sex},
address: ${address},
city: ${city},
state: ${state},
zipCode: ${zipCode},
number: ${number},
description: ${description},
selectedNeeds: ${selectedNeeds},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isEditing: ${isEditing},
canSubmit: ${canSubmit}
    ''';
  }
}
