import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

part 'profile_store.g.dart';

class ProfileStore = ProfileStoreBase with _$ProfileStore;

abstract class ProfileStoreBase with Store {
  ProfileStoreBase(this._getCurrentUser);

  final GetCurrentUserUsecase _getCurrentUser;

  @observable
  UserProfile? profile;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> load(String token) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      profile = await _getCurrentUser(token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar seu perfil.';
    } finally {
      isLoading = false;
    }
  }

  @action
  void clear() {
    profile = null;
    errorMessage = null;
  }
}
