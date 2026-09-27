// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recover_access_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RecoverAccessStore on RecoverAccessStoreBase, Store {
  Computed<bool>? _$canSubmitEmailComputed;

  @override
  bool get canSubmitEmail => (_$canSubmitEmailComputed ??= Computed<bool>(
    () => super.canSubmitEmail,
    name: 'RecoverAccessStoreBase.canSubmitEmail',
  )).value;
  Computed<bool>? _$canSubmitCodeComputed;

  @override
  bool get canSubmitCode => (_$canSubmitCodeComputed ??= Computed<bool>(
    () => super.canSubmitCode,
    name: 'RecoverAccessStoreBase.canSubmitCode',
  )).value;
  Computed<bool>? _$canResendCodeComputed;

  @override
  bool get canResendCode => (_$canResendCodeComputed ??= Computed<bool>(
    () => super.canResendCode,
    name: 'RecoverAccessStoreBase.canResendCode',
  )).value;
  Computed<bool>? _$canSubmitNewPasswordComputed;

  @override
  bool get canSubmitNewPassword =>
      (_$canSubmitNewPasswordComputed ??= Computed<bool>(
        () => super.canSubmitNewPassword,
        name: 'RecoverAccessStoreBase.canSubmitNewPassword',
      )).value;

  late final _$emailAtom = Atom(
    name: 'RecoverAccessStoreBase.email',
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

  late final _$codeAtom = Atom(
    name: 'RecoverAccessStoreBase.code',
    context: context,
  );

  @override
  String get code {
    _$codeAtom.reportRead();
    return super.code;
  }

  @override
  set code(String value) {
    _$codeAtom.reportWrite(value, super.code, () {
      super.code = value;
    });
  }

  late final _$passwordAtom = Atom(
    name: 'RecoverAccessStoreBase.password',
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
    name: 'RecoverAccessStoreBase.confirmPassword',
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

  late final _$resetTokenAtom = Atom(
    name: 'RecoverAccessStoreBase.resetToken',
    context: context,
  );

  @override
  String? get resetToken {
    _$resetTokenAtom.reportRead();
    return super.resetToken;
  }

  @override
  set resetToken(String? value) {
    _$resetTokenAtom.reportWrite(value, super.resetToken, () {
      super.resetToken = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'RecoverAccessStoreBase.isLoading',
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
    name: 'RecoverAccessStoreBase.errorMessage',
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

  late final _$resendSecondsRemainingAtom = Atom(
    name: 'RecoverAccessStoreBase.resendSecondsRemaining',
    context: context,
  );

  @override
  int get resendSecondsRemaining {
    _$resendSecondsRemainingAtom.reportRead();
    return super.resendSecondsRemaining;
  }

  @override
  set resendSecondsRemaining(int value) {
    _$resendSecondsRemainingAtom.reportWrite(
      value,
      super.resendSecondsRemaining,
      () {
        super.resendSecondsRemaining = value;
      },
    );
  }

  late final _$sendCodeAsyncAction = AsyncAction(
    'RecoverAccessStoreBase.sendCode',
    context: context,
  );

  @override
  Future<bool> sendCode() {
    return _$sendCodeAsyncAction.run(() => super.sendCode());
  }

  late final _$resendCodeAsyncAction = AsyncAction(
    'RecoverAccessStoreBase.resendCode',
    context: context,
  );

  @override
  Future<bool> resendCode() {
    return _$resendCodeAsyncAction.run(() => super.resendCode());
  }

  late final _$confirmCodeAsyncAction = AsyncAction(
    'RecoverAccessStoreBase.confirmCode',
    context: context,
  );

  @override
  Future<bool> confirmCode() {
    return _$confirmCodeAsyncAction.run(() => super.confirmCode());
  }

  late final _$submitNewPasswordAsyncAction = AsyncAction(
    'RecoverAccessStoreBase.submitNewPassword',
    context: context,
  );

  @override
  Future<bool> submitNewPassword() {
    return _$submitNewPasswordAsyncAction.run(() => super.submitNewPassword());
  }

  late final _$RecoverAccessStoreBaseActionController = ActionController(
    name: 'RecoverAccessStoreBase',
    context: context,
  );

  @override
  void setEmail(String value) {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase.setEmail',
    );
    try {
      return super.setEmail(value);
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCode(String value) {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase.setCode',
    );
    try {
      return super.setCode(value);
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase.setPassword',
    );
    try {
      return super.setPassword(value);
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setConfirmPassword(String value) {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase.setConfirmPassword',
    );
    try {
      return super.setConfirmPassword(value);
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear() {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase.clear',
    );
    try {
      return super.clear();
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _tickResendCountdown() {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase._tickResendCountdown',
    );
    try {
      return super._tickResendCountdown();
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
code: ${code},
password: ${password},
confirmPassword: ${confirmPassword},
resetToken: ${resetToken},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
resendSecondsRemaining: ${resendSecondsRemaining},
canSubmitEmail: ${canSubmitEmail},
canSubmitCode: ${canSubmitCode},
canResendCode: ${canResendCode},
canSubmitNewPassword: ${canSubmitNewPassword}
    ''';
  }
}
