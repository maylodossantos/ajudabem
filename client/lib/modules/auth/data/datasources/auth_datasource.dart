import '../../domain/entities/register_user_params.dart';
import '../../domain/entities/sign_in_params.dart';
import '../models/auth_session_model.dart';

abstract interface class AuthDatasource {
  Future<AuthSessionModel> register(RegisterUserParams params);

  Future<AuthSessionModel> signIn(SignInParams params);
}
