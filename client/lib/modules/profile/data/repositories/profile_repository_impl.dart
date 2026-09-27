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

  @override
  Future<UserProfile> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  }) async {
    final model = await _datasource.updateProfile(
      token,
      name: name,
      phone: phone,
      profileImage: profileImage,
      cpf: cpf,
      birthDate: birthDate,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteAccount(String token) {
    return _datasource.deleteAccount(token);
  }
}
