import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_in_params.dart';
import '../../domain/usecases/sign_in_usecase.dart';

part 'login_store.g.dart';

class LoginStore = LoginStoreBase with _$LoginStore;

abstract class LoginStoreBase with Store {
  LoginStoreBase(this._signIn);

  final SignInUsecase _signIn;
  AuthSession? _session;

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  bool isPasswordObscured = true;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? authenticatedUserName;

  String? get authToken => _session?.token;

  bool get isAuthenticated => _session != null;

  @computed
  bool get canSubmit => email.isNotEmpty && password.isNotEmpty && !isLoading;

  @action
  void setEmail(String value) {
    email = value;
    errorMessage = null;
  }

  @action
  void setPassword(String value) {
    password = value;
    errorMessage = null;
  }

  @action
  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
  }

  @action
  Future<bool> submit() async {
    if (!canSubmit) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      _session = await _signIn(SignInParams(email: email, password: password));
      authenticatedUserName = _session?.name;
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível entrar.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  void signOut() {
    _session = null;
    authenticatedUserName = null;
    password = '';
    errorMessage = null;
  }
}
