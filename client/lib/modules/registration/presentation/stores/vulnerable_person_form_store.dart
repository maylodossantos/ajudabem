import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/tags/tags_store.dart';
import '../../domain/entities/assisted_person.dart';
import '../../domain/entities/create_assisted_person_params.dart';
import '../../domain/repositories/assisted_person_repository.dart';

part 'vulnerable_person_form_store.g.dart';

class VulnerablePersonFormStore = VulnerablePersonFormStoreBase
    with _$VulnerablePersonFormStore;

abstract class VulnerablePersonFormStoreBase with Store {
  VulnerablePersonFormStoreBase(this._repository, this._tags);

  final AssistedPersonRepository _repository;
  final TagsStore _tags;

  @observable
  int? assistedPersonId;

  @observable
  bool? hasPersonalInformation;

  @observable
  bool? hasFixedAddress;

  @observable
  String name = '';

  @observable
  String age = '';

  @observable
  String sex = 'Masculino';

  @observable
  String address = '';

  @observable
  String city = '';

  @observable
  String state = 'Paraná';

  @observable
  String zipCode = '';

  @observable
  String number = '';

  @observable
  String description = '';

  @observable
  String locationDescription = '';

  @observable
  Set<String> selectedNeeds = {};

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get isEditing => assistedPersonId != null;

  @computed
  bool get asksIdentity => hasPersonalInformation != false;

  @computed
  bool get asksFixedAddress => hasFixedAddress != false;

  @computed
  bool get hasIdentity =>
      !asksIdentity ||
      (name.trim().isNotEmpty &&
          int.tryParse(age.trim()) != null &&
          sex.trim().isNotEmpty);

  @computed
  bool get hasLocation =>
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      (asksFixedAddress
          ? address.trim().isNotEmpty &&
                zipCode.trim().isNotEmpty &&
                number.trim().isNotEmpty
          : locationDescription.trim().isNotEmpty);

  @computed
  bool get canSubmit =>
      hasPersonalInformation != null &&
      hasFixedAddress != null &&
      hasIdentity &&
      hasLocation &&
      description.trim().isNotEmpty &&
      selectedNeeds.isNotEmpty &&
      !isLoading;

  @action
  void setHasPersonalInformation(bool value) {
    hasPersonalInformation = value;
  }

  @action
  void setHasFixedAddress(bool value) {
    hasFixedAddress = value;
  }

  @action
  void setName(String value) => name = value;

  @action
  void setAge(String value) => age = value;

  @action
  void setSex(String value) => sex = value;

  @action
  void setAddress(String value) => address = value;

  @action
  void setCity(String value) => city = value;

  @action
  void setState(String value) => state = value;

  @action
  void setZipCode(String value) => zipCode = value;

  @action
  void setNumber(String value) => number = value;

  @action
  void setDescription(String value) => description = value;

  @action
  void setLocationDescription(String value) => locationDescription = value;

  @action
  void toggleNeed(String need) {
    final updatedNeeds = Set<String>.from(selectedNeeds);
    updatedNeeds.contains(need)
        ? updatedNeeds.remove(need)
        : updatedNeeds.add(need);
    selectedNeeds = updatedNeeds;
  }

  bool isNeedSelected(String need) => selectedNeeds.contains(need);

  @action
  void populate(AssistedPerson person) {
    assistedPersonId = person.id;
    hasPersonalInformation = person.fullName != AssistedPerson.unidentifiedName;
    hasFixedAddress = person.street.isNotEmpty;
    name = hasPersonalInformation! ? person.fullName : '';
    age = person.age > 0 ? person.age.toString() : '';
    sex = _labelByGender[person.gender] ?? 'Outro';
    address = person.street;
    city = person.city;
    state = person.state.isEmpty ? 'Paraná' : person.state;
    zipCode = person.zipCode;
    number = person.number;
    description = person.notes;
    locationDescription = person.locationDescription;
    selectedNeeds = Set<String>.from(person.tags);
  }

  @action
  Future<bool> submit(String token) async {
    if (!canSubmit) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final params = _buildParams();
      final id = assistedPersonId;
      if (id == null) {
        await _repository.create(params, token);
      } else {
        await _repository.update(id, params, token);
      }
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível concluir o cadastro.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  static const _genderByLabel = {
    'Masculino': 'MALE',
    'Feminino': 'FEMALE',
    'Outro': 'OTHER',
    'Prefiro não informar': 'OTHER',
  };

  static const _labelByGender = {
    'MALE': 'Masculino',
    'FEMALE': 'Feminino',
    'OTHER': 'Outro',
  };

  CreateAssistedPersonParams _buildParams() {
    final identified = asksIdentity;
    final fixed = asksFixedAddress;
    return CreateAssistedPersonParams(
      identified: identified,
      fullName: identified ? name.trim() : '',
      age: identified ? int.parse(age.trim()) : null,
      gender: identified ? _genderByLabel[sex] ?? 'OTHER' : null,
      tagIds: _tags.idsOf(selectedNeeds),
      notes: description.trim(),
      street: fixed ? address.trim() : '',
      number: fixed ? number.trim() : '',
      neighborhood: '',
      city: city.trim(),
      state: state.trim(),
      zipCode: fixed ? zipCode.trim() : '',
      country: 'Brasil',
      locationDescription: fixed ? '' : locationDescription.trim(),
    );
  }
}
