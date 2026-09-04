import '../models/user_profile_model.dart';

abstract interface class ProfileDatasource {
  Future<UserProfileModel> getCurrentUser(String token);
}
