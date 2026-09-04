import '../entities/auth_session.dart';
import '../entities/sign_in_params.dart';
import '../repositories/auth_repository.dart';

class SignInUsecase {
  const SignInUsecase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call(SignInParams params) {
    final normalizedParams = SignInParams(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );

    return _repository.signIn(normalizedParams);
  }
}
