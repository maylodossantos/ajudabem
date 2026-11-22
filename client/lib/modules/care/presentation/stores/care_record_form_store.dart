import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/time_input_formatter.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/entities/care_record_params.dart';
import '../../domain/repositories/care_repository.dart';

part 'care_record_form_store.g.dart';

class CareRecordFormStore = CareRecordFormStoreBase with _$CareRecordFormStore;

abstract class CareRecordFormStoreBase with Store {
  CareRecordFormStoreBase(this._repository);

  final CareRepository _repository;

  @observable
  CareRecordStatus status = CareRecordStatus.inCare;

  @observable
  CareRecordStatus lastAction = CareRecordStatus.inCare;

  @computed
  bool get finishing => status == CareRecordStatus.finished;

  @observable
  String date = DateInputFormatter.display(DateTime.now());

  @observable
  String time = TimeInputFormatter.display(DateTime.now());

  @observable
  ObservableSet<String> needs = ObservableSet();

  @observable
  String situation = '';

  @observable
  String actionTaken = '';

  @observable
  String referral = '';

  @observable
  String nextStep = '';

  @observable
  String summary = '';

  @observable
  String note = '';

  @observable
  FinishReason? finishReason;

  @observable
  bool isSaving = false;

  @observable
  String? errorMessage;

  @computed
  DateTime? get occurredAt {
    final day = DateInputFormatter.parse(date);
    final minutes = TimeInputFormatter.parseMinutes(time);
    if (day == null || minutes == null) return null;
    return day.add(Duration(minutes: minutes));
  }

  @computed
  bool get canSubmit {
    final moment = occurredAt;
    return moment != null &&
        !moment.isAfter(DateTime.now()) &&
        (!finishing || finishReason != null) &&
        !isSaving;
  }

  @action
  void startWith(CareCase person, {required bool firstRecord}) {
    lastAction = CareRecordStatus.actionsFor(firstRecord: firstRecord).first;
    status = lastAction;
    needs = ObservableSet.of(person.needs);
  }

  @action
  void setStatus(CareRecordStatus value) {
    status = value;
    if (value != CareRecordStatus.finished) lastAction = value;
  }

  @action
  void startFinishing() => status = CareRecordStatus.finished;

  @action
  void cancelFinishing() => status = lastAction;

  @action
  void setDate(String value) => date = value;

  @action
  void setTime(String value) => time = value;

  @action
  void toggleNeed(String need) {
    if (!needs.remove(need)) needs.add(need);
  }

  @action
  void setSituation(String value) => situation = value;

  @action
  void setActionTaken(String value) => actionTaken = value;

  @action
  void setReferral(String value) => referral = value;

  @action
  void setNextStep(String value) => nextStep = value;

  @action
  void setSummary(String value) => summary = value;

  @action
  void setNote(String value) => note = value;

  @action
  void setFinishReason(FinishReason value) => finishReason = value;

  @action
  Future<CareCaseDetail?> submit(
    int personId,
    String token, {
    required List<int> Function(Iterable<String>) tagIdsOf,
  }) async {
    final moment = occurredAt;
    if (!canSubmit || moment == null) return null;

    isSaving = true;
    errorMessage = null;

    try {
      return await _repository.addRecord(
        personId,
        CareRecordParams(
          status: status,
          occurredAt: moment,
          tagIds: tagIdsOf(needs),
          situation: status.asksSituation ? situation : '',
          actionTaken: status.asksActionTaken ? actionTaken : '',
          referral: status.asksReferral ? referral : '',
          nextStep: status.asksNextStep ? nextStep : '',
          summary: finishing ? summary : '',
          note: note,
          finishReason: finishing ? finishReason : null,
        ),
        token,
      );
    } on AppException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Não foi possível salvar o atendimento.';
      return null;
    } finally {
      isSaving = false;
    }
  }
}
