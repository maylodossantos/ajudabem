// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterStore on RegisterStoreBase, Store {
  Computed<bool>? _$passwordsMatchComputed;

  @override
  bool get passwordsMatch => (_$passwordsMatchComputed ??= Computed<bool>(
    () => super.passwordsMatch,
    name: 'RegisterStoreBase.passwordsMatch',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'RegisterStoreBase.canSubmit',
  )).value;

  late final _$nameAtom = Atom(
    name: 'RegisterStoreBase.name',
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

  late final _$emailAtom = Atom(
    name: 'RegisterStoreBase.email',
    context: context,
  );

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$phoneAtom = Atom(
    name: 'RegisterStoreBase.phone',
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

  late final _$passwordAtom = Atom(
    name: 'RegisterStoreBase.password',
    context: context,
  );

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$confirmPasswordAtom = Atom(
    name: 'RegisterStoreBase.confirmPassword',
    context: context,
  );

  @override
  String get confirmPassword {
    _$confirmPasswordAtom.reportRead();
    return super.confirmPassword;
  }

  @override
  set confirmPassword(String value) {
    _$confirmPasswordAtom.reportWrite(value, super.confirmPassword, () {
      super.confirmPassword = value;
    });
  }

  late final _$isPasswordObscuredAtom = Atom(
    name: 'RegisterStoreBase.isPasswordObscured',
    context: context,
  );

  @override
  bool get isPasswordObscured {
    _$isPasswordObscuredAtom.reportRead();
    return super.isPasswordObscured;
  }

  @override
  set isPasswordObscured(bool value) {
    _$isPasswordObscuredAtom.reportWrite(value, super.isPasswordObscured, () {
      super.isPasswordObscured = value;
    });
  }

  late final _$isConfirmPasswordObscuredAtom = Atom(
    name: 'RegisterStoreBase.isConfirmPasswordObscured',
    context: context,
  );

  @override
  bool get isConfirmPasswordObscured {
    _$isConfirmPasswordObscuredAtom.reportRead();
    return super.isConfirmPasswordObscured;
  }

  @override
  set isConfirmPasswordObscured(bool value) {
    _$isConfirmPasswordObscuredAtom.reportWrite(
      value,
      super.isConfirmPasswordObscured,
      () {
        super.isConfirmPasswordObscured = value;
      },
    );
  }

  late final _$acceptedTermsAtom = Atom(
    name: 'RegisterStoreBase.acceptedTerms',
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

  late final _$isLoadingAtom = Atom(
    name: 'RegisterStoreBase.isLoading',
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
    name: 'RegisterStoreBase.errorMessage',
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
    'RegisterStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit() {
    return _$submitAsyncAction.run(() => super.submit());
  }

  late final _$RegisterStoreBaseActionController = ActionController(
    name: 'RegisterStoreBase',
    context: context,
  );

  @override
  void setName(String value) {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.setName',
    );
    try {
      return super.setName(value);
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String value) {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.setEmail',
    );
    try {
      return super.setEmail(value);
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String value) {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.setPhone',
    );
    try {
      return super.setPhone(value);
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.setPassword',
    );
    try {
      return super.setPassword(value);
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setConfirmPassword(String value) {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.setConfirmPassword',
    );
    try {
      return super.setConfirmPassword(value);
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void togglePasswordVisibility() {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.togglePasswordVisibility',
    );
    try {
      return super.togglePasswordVisibility();
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleConfirmPasswordVisibility() {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.toggleConfirmPasswordVisibility',
    );
    try {
      return super.toggleConfirmPasswordVisibility();
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAcceptedTerms(bool value) {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.setAcceptedTerms',
    );
    try {
      return super.setAcceptedTerms(value);
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear() {
    final _$actionInfo = _$RegisterStoreBaseActionController.startAction(
      name: 'RegisterStoreBase.clear',
    );
    try {
      return super.clear();
    } finally {
      _$RegisterStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
email: ${email},
phone: ${phone},
password: ${password},
confirmPassword: ${confirmPassword},
isPasswordObscured: ${isPasswordObscured},
isConfirmPasswordObscured: ${isConfirmPasswordObscured},
acceptedTerms: ${acceptedTerms},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
passwordsMatch: ${passwordsMatch},
canSubmit: ${canSubmit}
    ''';
  }
}
