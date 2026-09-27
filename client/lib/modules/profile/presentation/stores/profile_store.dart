import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_store.g.dart';

class ProfileStore = ProfileStoreBase with _$ProfileStore;

abstract class ProfileStoreBase with Store {
  ProfileStoreBase(this._repository);

  final ProfileRepository _repository;

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
      profile = await _repository.getCurrentUser(token);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar seu perfil.';
    } finally {
      isLoading = false;
    }
  }

  @action
  void updateProfile(UserProfile updated) {
    profile = updated;
  }

  @action
  Future<bool> deleteAccount(String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _repository.deleteAccount(token);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível excluir sua conta.';
      return false;
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
