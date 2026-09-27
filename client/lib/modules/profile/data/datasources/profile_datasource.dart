import '../models/user_profile_model.dart';

abstract interface class ProfileDatasource {
  Future<UserProfileModel> getCurrentUser(String token);

  Future<UserProfileModel> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  });

  Future<void> deleteAccount(String token);
}
