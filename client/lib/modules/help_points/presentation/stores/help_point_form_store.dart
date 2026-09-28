import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/masked_input_formatter.dart';
import '../../../../core/formatters/phone_input_formatter.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/stores/image_upload_store.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_form_params.dart';
import '../../domain/repositories/help_point_repository.dart';

part 'help_point_form_store.g.dart';

class HelpPointFormStore = HelpPointFormStoreBase with _$HelpPointFormStore;

abstract class HelpPointFormStoreBase with Store {
  HelpPointFormStoreBase(this._repository, ImageUploadService imageUpload)
    : cover = ImageUploadStore(imageUpload);

  final HelpPointRepository _repository;

  final ImageUploadStore cover;

  static const defaultOpensAt = 8 * 60;
  static const defaultClosesAt = 18 * 60;

  @observable
  int? editingId;

  @observable
  String name = '';

  @observable
  String description = '';

  @observable
  HelpPointOrganizationType? organizationType;

  @observable
  ObservableSet<AssistanceType> services = ObservableSet();

  @observable
  String street = '';

  @observable
  String number = '';

  @observable
  String neighborhood = '';

  @observable
  String city = '';

  @observable
  String? state;

  @observable
  String zipCode = '';

  @observable
  String phone = '';

  @observable
  String whatsapp = '';

  @observable
  String email = '';

  @observable
  String responsible = '';

  @observable
  ObservableMap<int, OpeningHours> hours = ObservableMap();

  @observable
  String scheduleNote = '';

  @observable
  String notes = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  HelpPoint? saved;

  @computed
  bool get isEditing => editingId != null;

  @computed
  bool get canSubmit =>
      name.trim().isNotEmpty &&
      organizationType != null &&
      services.isNotEmpty &&
      street.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state != null &&
      (zipCode.isEmpty || CepInputFormatter.isComplete(zipCode)) &&
      (email.trim().isEmpty || email.contains('@')) &&
      !isLoading &&
      !cover.isUploading;

  @action
  void populate(HelpPoint point) {
    editingId = point.id;
    name = point.name;
    description = point.description;
    organizationType = point.organizationType;
    services = ObservableSet.of(point.services);
    street = point.street;
    number = point.number;
    neighborhood = point.neighborhood;
    city = point.city;
    state = point.state.isEmpty ? null : point.state;
    zipCode = CepInputFormatter.display(point.zipCode);
    phone = PhoneInputFormatter.format(point.phone ?? '');
    whatsapp = PhoneInputFormatter.format(point.whatsapp ?? '');
    email = point.email ?? '';
    responsible = point.responsible ?? '';
    hours = ObservableMap.of({
      for (final day in point.openingHours) day.weekday: day,
    });
    scheduleNote = point.scheduleNote ?? '';
    notes = point.notes ?? '';
    cover.setImageUrl(point.coverImage);
  }

  @action
  void setName(String value) => name = value;

  @action
  void setDescription(String value) => description = value;

  @action
  void setOrganizationType(HelpPointOrganizationType value) =>
      organizationType = value;

  @action
  void toggleService(AssistanceType type) {
    if (!services.remove(type)) services.add(type);
  }

  @action
  void setStreet(String value) => street = value;

  @action
  void setNumber(String value) => number = value;

  @action
  void setNeighborhood(String value) => neighborhood = value;

  @action
  void setCity(String value) => city = value;

  @action
  void setState(String value) => state = value;

  @action
  void setZipCode(String value) => zipCode = value;

  @action
  void setPhone(String value) => phone = value;

  @action
  void setWhatsapp(String value) => whatsapp = value;

  @action
  void setEmail(String value) => email = value;

  @action
  void setResponsible(String value) => responsible = value;

  @action
  void setScheduleNote(String value) => scheduleNote = value;

  @action
  void setNotes(String value) => notes = value;

  @action
  void setDayOpen(int weekday, bool open) {
    if (!open) {
      hours.remove(weekday);
      return;
    }
    hours[weekday] = OpeningHours(
      weekday: weekday,
      opensAt: defaultOpensAt,
      closesAt: defaultClosesAt,
    );
  }

  @action
  void setDayAllDay(int weekday, bool allDay) {
    hours[weekday] = OpeningHours(
      weekday: weekday,
      opensAt: allDay ? 0 : defaultOpensAt,
      closesAt: allDay ? 0 : defaultClosesAt,
    );
  }

  @action
  void setDayTimes(int weekday, {int? opensAt, int? closesAt}) {
    final current = hours[weekday];
    if (current == null) return;
    hours[weekday] = OpeningHours(
      weekday: weekday,
      opensAt: opensAt ?? current.opensAt,
      closesAt: closesAt ?? current.closesAt,
    );
  }

  @action
  void applyToAllDays(int weekday) {
    final source = hours[weekday];
    if (source == null) return;
    for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
      hours[day] = OpeningHours(
        weekday: day,
        opensAt: source.opensAt,
        closesAt: source.closesAt,
      );
    }
  }

  @action
  Future<bool> submit(String token) async {
    if (!canSubmit) return false;

    isLoading = true;
    errorMessage = null;

    final params = HelpPointFormParams(
      name: name,
      description: description,
      coverImage: cover.imageUrl,
      organizationType: organizationType!,
      services: Set.of(services),
      street: street,
      number: number,
      neighborhood: neighborhood,
      city: city,
      state: state!,
      zipCode: MaskedInputFormatter.digitsOnly(zipCode),
      phone: PhoneInputFormatter.digitsOnly(phone),
      whatsapp: PhoneInputFormatter.digitsOnly(whatsapp),
      email: email,
      responsible: responsible,
      openingHours: [
        for (var day = DateTime.monday; day <= DateTime.sunday; day++)
          ?hours[day],
      ],
      scheduleNote: scheduleNote,
      notes: notes,
    );

    try {
      final id = editingId;
      saved = id == null
          ? await _repository.create(params, token)
          : await _repository.update(id, params, token);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível salvar o ponto de ajuda.';
      return false;
    } finally {
      isLoading = false;
    }
  }
}
