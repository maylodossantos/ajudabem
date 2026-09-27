// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_edit_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileEditStore on ProfileEditStoreBase, Store {
  Computed<bool>? _$isCpfValidComputed;

  @override
  bool get isCpfValid => (_$isCpfValidComputed ??= Computed<bool>(
    () => super.isCpfValid,
    name: 'ProfileEditStoreBase.isCpfValid',
  )).value;
  Computed<bool>? _$isBirthDateValidComputed;

  @override
  bool get isBirthDateValid => (_$isBirthDateValidComputed ??= Computed<bool>(
    () => super.isBirthDateValid,
    name: 'ProfileEditStoreBase.isBirthDateValid',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'ProfileEditStoreBase.canSubmit',
  )).value;

  late final _$nameAtom = Atom(
    name: 'ProfileEditStoreBase.name',
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

  late final _$phoneAtom = Atom(
    name: 'ProfileEditStoreBase.phone',
    context: context,
  );

  @override
  String get phone {
    _$phoneAtom.reportRead();
    return super.phone;
  }

  @override
  set phone(String value) {
    _$phoneAtom.reportWrite(value, super.phone, () {
      super.phone = value;
    });
  }

  late final _$cpfAtom = Atom(
    name: 'ProfileEditStoreBase.cpf',
    context: context,
  );

  @override
  String get cpf {
    _$cpfAtom.reportRead();
    return super.cpf;
  }

  @override
  set cpf(String value) {
    _$cpfAtom.reportWrite(value, super.cpf, () {
      super.cpf = value;
    });
  }

  late final _$birthDateAtom = Atom(
    name: 'ProfileEditStoreBase.birthDate',
    context: context,
  );

  @override
  String get birthDate {
    _$birthDateAtom.reportRead();
    return super.birthDate;
  }

  @override
  set birthDate(String value) {
    _$birthDateAtom.reportWrite(value, super.birthDate, () {
      super.birthDate = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'ProfileEditStoreBase.isLoading',
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
    name: 'ProfileEditStoreBase.errorMessage',
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

  late final _$savedProfileAtom = Atom(
    name: 'ProfileEditStoreBase.savedProfile',
    context: context,
  );

  @override
  UserProfile? get savedProfile {
    _$savedProfileAtom.reportRead();
    return super.savedProfile;
  }

  @override
  set savedProfile(UserProfile? value) {
    _$savedProfileAtom.reportWrite(value, super.savedProfile, () {
      super.savedProfile = value;
    });
  }

  late final _$saveAsyncAction = AsyncAction(
    'ProfileEditStoreBase.save',
    context: context,
  );

  @override
  Future<bool> save(String token) {
    return _$saveAsyncAction.run(() => super.save(token));
  }

  late final _$ProfileEditStoreBaseActionController = ActionController(
    name: 'ProfileEditStoreBase',
    context: context,
  );

  @override
  void init(UserProfile profile) {
    final _$actionInfo = _$ProfileEditStoreBaseActionController.startAction(
      name: 'ProfileEditStoreBase.init',
    );
    try {
      return super.init(profile);
    } finally {
      _$ProfileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setName(String value) {
    final _$actionInfo = _$ProfileEditStoreBaseActionController.startAction(
      name: 'ProfileEditStoreBase.setName',
    );
    try {
      return super.setName(value);
    } finally {
      _$ProfileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String value) {
    final _$actionInfo = _$ProfileEditStoreBaseActionController.startAction(
      name: 'ProfileEditStoreBase.setPhone',
    );
    try {
      return super.setPhone(value);
    } finally {
      _$ProfileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCpf(String value) {
    final _$actionInfo = _$ProfileEditStoreBaseActionController.startAction(
      name: 'ProfileEditStoreBase.setCpf',
    );
    try {
      return super.setCpf(value);
    } finally {
      _$ProfileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBirthDate(String value) {
    final _$actionInfo = _$ProfileEditStoreBaseActionController.startAction(
      name: 'ProfileEditStoreBase.setBirthDate',
    );
    try {
      return super.setBirthDate(value);
    } finally {
      _$ProfileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
phone: ${phone},
cpf: ${cpf},
birthDate: ${birthDate},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
savedProfile: ${savedProfile},
isCpfValid: ${isCpfValid},
isBirthDateValid: ${isBirthDateValid},
canSubmit: ${canSubmit}
    ''';
  }
}
