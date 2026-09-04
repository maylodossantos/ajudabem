import '../../domain/entities/auth_session.dart';
import '../../domain/entities/register_user_params.dart';
import '../../domain/entities/sign_in_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<AuthSession> register(RegisterUserParams params) async {
    final model = await _datasource.register(params);
    return model.toEntity();
  }

  @override
  Future<AuthSession> signIn(SignInParams params) async {
    final model = await _datasource.signIn(params);
    return model.toEntity();
  }
}
