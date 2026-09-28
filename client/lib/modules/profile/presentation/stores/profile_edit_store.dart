import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/cpf_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/masked_input_formatter.dart';
import '../../../../core/formatters/phone_input_formatter.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/stores/image_upload_store.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_edit_store.g.dart';

class ProfileEditStore = ProfileEditStoreBase with _$ProfileEditStore;

abstract class ProfileEditStoreBase with Store {
  ProfileEditStoreBase(this._repository, ImageUploadService imageUploadService)
    : photo = ImageUploadStore(imageUploadService);

  final ProfileRepository _repository;
  final ImageUploadStore photo;

  @observable
  String name = '';

  @observable
  String phone = '';

  @observable
  String cpf = '';

  @observable
  String birthDate = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  UserProfile? savedProfile;

  @computed
  bool get isCpfValid => cpf.isEmpty || CpfInputFormatter.isComplete(cpf);

  @computed
  bool get isBirthDateValid =>
      birthDate.isEmpty || DateInputFormatter.parseBirthDate(birthDate) != null;

  @computed
  bool get canSubmit =>
      name.trim().isNotEmpty &&
      isCpfValid &&
      isBirthDateValid &&
      !isLoading &&
      !photo.isUploading;

  @action
  void init(UserProfile profile) {
    name = profile.name;
    phone = profile.phone;
    cpf = CpfInputFormatter.display(profile.cpf);
    birthDate = DateInputFormatter.display(profile.birthDate);
    photo.setImageUrl(profile.profileImage);
    errorMessage = null;
  }

  @action
  void setName(String value) => name = value;

  @action
  void setPhone(String value) => phone = value;

  @action
  void setCpf(String value) => cpf = value;

  @action
  void setBirthDate(String value) => birthDate = value;

  @action
  Future<bool> save(String token) async {
    if (!canSubmit) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      savedProfile = await _repository.updateProfile(
        token,
        name: name.trim(),
        phone: PhoneInputFormatter.digitsOnly(phone),
        profileImage: photo.imageUrl,
        cpf: cpf.isEmpty ? null : MaskedInputFormatter.digitsOnly(cpf),
        birthDate: DateInputFormatter.parseBirthDate(birthDate),
      );
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível salvar as alterações do perfil.';
      return false;
    } finally {
      isLoading = false;
    }
  }
}
