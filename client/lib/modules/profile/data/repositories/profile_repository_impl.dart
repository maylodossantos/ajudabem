import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileDatasource _datasource;

  @override
  Future<UserProfile> getCurrentUser(String token) async {
    final model = await _datasource.getCurrentUser(token);
    return model.toEntity();
  }
}
