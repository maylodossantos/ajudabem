import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getCurrentUser(String token);

  Future<UserProfile> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  });

  Future<void> deleteAccount(String token);
}
