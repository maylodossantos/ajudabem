// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoginStore on LoginStoreBase, Store {
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'LoginStoreBase.canSubmit',
  )).value;

  late final _$emailAtom = Atom(name: 'LoginStoreBase.email', context: context);

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

  late final _$passwordAtom = Atom(
    name: 'LoginStoreBase.password',
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

  late final _$isPasswordObscuredAtom = Atom(
    name: 'LoginStoreBase.isPasswordObscured',
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

  late final _$isLoadingAtom = Atom(
    name: 'LoginStoreBase.isLoading',
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
    name: 'LoginStoreBase.errorMessage',
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

  late final _$authenticatedUserNameAtom = Atom(
    name: 'LoginStoreBase.authenticatedUserName',
    context: context,
  );

  @override
  String? get authenticatedUserName {
    _$authenticatedUserNameAtom.reportRead();
    return super.authenticatedUserName;
  }

  @override
  set authenticatedUserName(String? value) {
    _$authenticatedUserNameAtom.reportWrite(
      value,
      super.authenticatedUserName,
      () {
        super.authenticatedUserName = value;
      },
    );
  }

  late final _$submitAsyncAction = AsyncAction(
    'LoginStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit() {
    return _$submitAsyncAction.run(() => super.submit());
  }

  late final _$LoginStoreBaseActionController = ActionController(
    name: 'LoginStoreBase',
    context: context,
  );

  @override
  void setEmail(String value) {
    final _$actionInfo = _$LoginStoreBaseActionController.startAction(
      name: 'LoginStoreBase.setEmail',
    );
    try {
      return super.setEmail(value);
    } finally {
      _$LoginStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$LoginStoreBaseActionController.startAction(
      name: 'LoginStoreBase.setPassword',
    );
    try {
      return super.setPassword(value);
    } finally {
      _$LoginStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void togglePasswordVisibility() {
    final _$actionInfo = _$LoginStoreBaseActionController.startAction(
      name: 'LoginStoreBase.togglePasswordVisibility',
    );
    try {
      return super.togglePasswordVisibility();
    } finally {
      _$LoginStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void signOut() {
    final _$actionInfo = _$LoginStoreBaseActionController.startAction(
      name: 'LoginStoreBase.signOut',
    );
    try {
      return super.signOut();
    } finally {
      _$LoginStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
password: ${password},
isPasswordObscured: ${isPasswordObscured},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
authenticatedUserName: ${authenticatedUserName},
canSubmit: ${canSubmit}
    ''';
  }
}
