import '../entities/auth_session.dart';
import '../entities/register_user_params.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUsecase {
  const RegisterUserUsecase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call(RegisterUserParams params) {
    final normalizedParams = RegisterUserParams(
      name: params.name.trim(),
      email: params.email.trim().toLowerCase(),
      phone: params.phone.trim(),
      password: params.password,
    );

    return _repository.register(normalizedParams);
  }
}
