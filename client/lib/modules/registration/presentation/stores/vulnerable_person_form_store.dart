import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/assisted_person.dart';
import '../../domain/entities/create_assisted_person_params.dart';
import '../../domain/usecases/create_assisted_person_usecase.dart';
import '../../domain/usecases/update_assisted_person_usecase.dart';

part 'vulnerable_person_form_store.g.dart';

class VulnerablePersonFormStore = VulnerablePersonFormStoreBase
    with _$VulnerablePersonFormStore;

abstract class VulnerablePersonFormStoreBase with Store {
  VulnerablePersonFormStoreBase(
    this._createAssistedPerson,
    this._updateAssistedPerson,
  );

  final CreateAssistedPersonUsecase _createAssistedPerson;
  final UpdateAssistedPersonUsecase _updateAssistedPerson;

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
  Set<String> selectedNeeds = {};

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get isEditing => assistedPersonId != null;

  @computed
  bool get canSubmit =>
      hasPersonalInformation != null &&
      hasFixedAddress != null &&
      name.trim().isNotEmpty &&
      int.tryParse(age.trim()) != null &&
      sex.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      zipCode.trim().isNotEmpty &&
      number.trim().isNotEmpty &&
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
    hasPersonalInformation = true;
    hasFixedAddress = person.street.isNotEmpty;
    name = person.fullName;
    age = person.age > 0 ? person.age.toString() : '';
    sex = _labelByGender[person.gender] ?? 'Outro';
    address = person.street;
    city = person.city;
    state = person.state.isEmpty ? 'Paraná' : person.state;
    zipCode = person.zipCode;
    number = person.number;
    description = person.notes;
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
        await _createAssistedPerson(params, token);
      } else {
        await _updateAssistedPerson(id, params, token);
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

  static const _tagIdByNeed = {
    'Alimentação': 1,
    'Moradia': 2,
    'Saúde': 3,
    'Apoio emocional': 4,
    'Reabilitação': 5,
  };

  CreateAssistedPersonParams _buildParams() {
    return CreateAssistedPersonParams(
      fullName: name.trim(),
      age: int.parse(age.trim()),
      gender: _genderByLabel[sex] ?? 'OTHER',
      tagIds: selectedNeeds
          .map((need) => _tagIdByNeed[need])
          .whereType<int>()
          .toList(),
      notes: description.trim(),
      street: address.trim(),
      number: number.trim(),
      neighborhood: '',
      city: city.trim(),
      state: state.trim(),
      zipCode: zipCode.trim(),
      country: 'Brasil',
    );
  }
}
