import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/register_user_params.dart';
import '../../domain/usecases/register_user_usecase.dart';

part 'register_store.g.dart';

class RegisterStore = RegisterStoreBase with _$RegisterStore;

abstract class RegisterStoreBase with Store {
  RegisterStoreBase(this._registerUser);

  final RegisterUserUsecase _registerUser;

  @observable
  String name = '';

  @observable
  String email = '';

  @observable
  String phone = '';

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  bool isPasswordObscured = true;

  @observable
  bool isConfirmPasswordObscured = true;

  @observable
  bool acceptedTerms = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get passwordsMatch =>
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      password == confirmPassword;

  @computed
  bool get canSubmit =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      passwordsMatch &&
      acceptedTerms &&
      !isLoading;

  @action
  void setName(String value) {
    name = value;
  }

  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setPhone(String value) {
    phone = value;
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
  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
  }

  @action
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured = !isConfirmPasswordObscured;
  }

  @action
  void setAcceptedTerms(bool value) {
    acceptedTerms = value;
  }

  @action
  Future<bool> submit() async {
    if (!canSubmit) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await _registerUser(
        RegisterUserParams(
          name: name,
          email: email,
          phone: phone,
          password: password,
        ),
      );
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível realizar o cadastro.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void clear() {
    name = '';
    email = '';
    phone = '';
    password = '';
    confirmPassword = '';
    acceptedTerms = false;
    errorMessage = null;
  }
}
