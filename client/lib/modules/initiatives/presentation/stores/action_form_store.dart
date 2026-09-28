import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/masked_input_formatter.dart';
import '../../../../core/formatters/time_input_formatter.dart';
import '../../domain/entities/volunteer_action.dart';
import '../../domain/repositories/initiative_repositories.dart';

part 'action_form_store.g.dart';

class ActionFormStore = ActionFormStoreBase with _$ActionFormStore;

abstract class ActionFormStoreBase with Store {
  ActionFormStoreBase(this._repository);

  final VolunteerActionRepository _repository;

  @observable
  int? actionId;

  @observable
  String title = '';

  @observable
  String date = '';

  @observable
  String startTime = '';

  @observable
  String endTime = '';

  @observable
  String volunteers = '';

  @observable
  String street = '';

  @observable
  String number = '';

  @observable
  String city = '';

  @observable
  String state = 'PR';

  @observable
  String zipCode = '';

  @observable
  String description = '';

  @observable
  String tasks = '';

  @observable
  String requirements = '';

  @observable
  String notes = '';

  @observable
  bool isSaving = false;

  @observable
  String? errorMessage;

  @computed
  DateTime? get actionDate {
    final parsed = DateInputFormatter.parse(date);
    final now = DateTime.now();
    if (parsed == null ||
        parsed.isBefore(DateTime(now.year, now.month, now.day))) {
      return null;
    }
    return parsed;
  }

  @computed
  bool get timesValid {
    final start = TimeInputFormatter.parseMinutes(startTime);
    final end = TimeInputFormatter.parseMinutes(endTime);
    return start != null && end != null && end > start;
  }

  @computed
  int? get volunteersNeeded {
    final value = int.tryParse(volunteers);
    return value == null || value < 1 || value > 1000 ? null : value;
  }

  @computed
  bool get canSubmit =>
      title.trim().isNotEmpty &&
      actionDate != null &&
      timesValid &&
      volunteersNeeded != null &&
      street.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      !isSaving;

  @action
  void populate(VolunteerAction action) {
    actionId = action.id;
    title = action.title;
    date = DateInputFormatter.display(action.date);
    startTime = action.startTime;
    endTime = action.endTime;
    volunteers = '${action.volunteersNeeded}';
    street = action.street;
    number = action.number;
    city = action.city;
    state = action.state.isEmpty ? 'PR' : action.state;
    zipCode = action.zipCode;
    description = action.description;
    tasks = action.tasks;
    requirements = action.requirements;
    notes = action.notes;
  }

  @action
  void setTitle(String value) => title = value;

  @action
  void setDate(String value) => date = value;

  @action
  void setStartTime(String value) => startTime = value;

  @action
  void setEndTime(String value) => endTime = value;

  @action
  void setVolunteers(String value) => volunteers = value;

  @action
  void setStreet(String value) => street = value;

  @action
  void setNumber(String value) => number = value;

  @action
  void setCity(String value) => city = value;

  @action
  void setState(String value) => state = value;

  @action
  void setZipCode(String value) => zipCode = value;

  @action
  void setDescription(String value) => description = value;

  @action
  void setTasks(String value) => tasks = value;

  @action
  void setRequirements(String value) => requirements = value;

  @action
  void setNotes(String value) => notes = value;

  @action
  Future<VolunteerAction?> submit(String token) async {
    final day = actionDate;
    final needed = volunteersNeeded;
    if (!canSubmit || day == null || needed == null) return null;
    isSaving = true;
    errorMessage = null;

    try {
      return await _repository.save(
        VolunteerActionParams(
          title: title,
          date: day,
          startTime: startTime,
          endTime: endTime,
          volunteersNeeded: needed,
          street: street,
          number: number,
          city: city,
          state: state,
          zipCode: MaskedInputFormatter.digitsOnly(zipCode),
          description: description,
          tasks: tasks,
          requirements: requirements,
          notes: notes,
        ),
        token,
        id: actionId,
      );
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível salvar a ação.',
      );
      return null;
    } finally {
      isSaving = false;
    }
  }
}
