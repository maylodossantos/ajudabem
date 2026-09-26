import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';

part 'recover_access_store.g.dart';

const resendCodeCooldownSeconds = 55;

class RecoverAccessStore = RecoverAccessStoreBase with _$RecoverAccessStore;

abstract class RecoverAccessStoreBase with Store implements Disposable {
  RecoverAccessStoreBase(this._repository);

  final AuthRepository _repository;

  Timer? _resendCountdownTimer;

  @observable
  String email = '';

  @observable
  String code = '';

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  String? resetToken;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int resendSecondsRemaining = 0;

  @computed
  bool get canSubmitEmail => email.trim().isNotEmpty && !isLoading;

  @computed
  bool get canSubmitCode => code.trim().length == 4 && !isLoading;

  @computed
  bool get canResendCode => resendSecondsRemaining <= 0 && !isLoading;

  @computed
  bool get canSubmitNewPassword =>
      password.isNotEmpty && confirmPassword.isNotEmpty && !isLoading;

  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setCode(String value) {
    code = value;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
  }

  @action
  Future<bool> sendCode() async {
    if (!canSubmitEmail) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await _repository.forgotPassword(email.trim());
      _startResendCountdown();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível enviar o código.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> resendCode() async {
    if (!canResendCode) {
      return false;
    }

    return sendCode();
  }

  @action
  Future<bool> confirmCode() async {
    if (!canSubmitCode) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      resetToken = await _repository.verifyCode(email.trim(), code.trim());
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível verificar o código.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> submitNewPassword() async {
    final token = resetToken;
    if (!canSubmitNewPassword || token == null) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await _repository.resetPassword(
        email: email.trim(),
        resetToken: token,
        password: password,
        confirmPassword: confirmPassword,
      );
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível redefinir a senha.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void clear() {
    email = '';
    code = '';
    password = '';
    confirmPassword = '';
    resetToken = null;
    errorMessage = null;
    _resendCountdownTimer?.cancel();
    resendSecondsRemaining = 0;
  }

  void _startResendCountdown() {
    _resendCountdownTimer?.cancel();
    resendSecondsRemaining = resendCodeCooldownSeconds;
    _resendCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickResendCountdown(),
    );
  }

  @action
  void _tickResendCountdown() {
    if (resendSecondsRemaining <= 1) {
      resendSecondsRemaining = 0;
      _resendCountdownTimer?.cancel();
    } else {
      resendSecondsRemaining -= 1;
    }
  }

  @override
  void dispose() {
    _resendCountdownTimer?.cancel();
  }
}
