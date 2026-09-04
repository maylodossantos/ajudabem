import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetCurrentUserUsecase {
  const GetCurrentUserUsecase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> call(String token) {
    return _repository.getCurrentUser(token);
  }
}
