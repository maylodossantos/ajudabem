import '../entities/auth_session.dart';
import '../entities/register_user_params.dart';
import '../entities/sign_in_params.dart';

abstract interface class AuthRepository {
  Future<AuthSession> register(RegisterUserParams params);

  Future<AuthSession> signIn(SignInParams params);
}
