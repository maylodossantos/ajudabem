// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_record_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CareRecordFormStore on CareRecordFormStoreBase, Store {
  Computed<DateTime?>? _$occurredAtComputed;

  @override
  DateTime? get occurredAt => (_$occurredAtComputed ??= Computed<DateTime?>(
    () => super.occurredAt,
    name: 'CareRecordFormStoreBase.occurredAt',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'CareRecordFormStoreBase.canSubmit',
  )).value;

  late final _$statusAtom = Atom(
    name: 'CareRecordFormStoreBase.status',
    context: context,
  );

  @override
  CareRecordStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(CareRecordStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$dateAtom = Atom(
    name: 'CareRecordFormStoreBase.date',
    context: context,
  );

  @override
  String get date {
    _$dateAtom.reportRead();
    return super.date;
  }

  @override
  set date(String value) {
    _$dateAtom.reportWrite(value, super.date, () {
      super.date = value;
    });
  }

  late final _$timeAtom = Atom(
    name: 'CareRecordFormStoreBase.time',
    context: context,
  );

  @override
  String get time {
    _$timeAtom.reportRead();
    return super.time;
  }

  @override
  set time(String value) {
    _$timeAtom.reportWrite(value, super.time, () {
      super.time = value;
    });
  }

  late final _$needsAtom = Atom(
    name: 'CareRecordFormStoreBase.needs',
    context: context,
  );

  @override
  ObservableSet<String> get needs {
    _$needsAtom.reportRead();
    return super.needs;
  }

  @override
  set needs(ObservableSet<String> value) {
    _$needsAtom.reportWrite(value, super.needs, () {
      super.needs = value;
    });
  }

  late final _$situationAtom = Atom(
    name: 'CareRecordFormStoreBase.situation',
    context: context,
  );

  @override
  String get situation {
    _$situationAtom.reportRead();
    return super.situation;
  }

  @override
  set situation(String value) {
    _$situationAtom.reportWrite(value, super.situation, () {
      super.situation = value;
    });
  }

  late final _$actionTakenAtom = Atom(
    name: 'CareRecordFormStoreBase.actionTaken',
    context: context,
  );

  @override
  String get actionTaken {
    _$actionTakenAtom.reportRead();
    return super.actionTaken;
  }

  @override
  set actionTaken(String value) {
    _$actionTakenAtom.reportWrite(value, super.actionTaken, () {
      super.actionTaken = value;
    });
  }

  late final _$referralAtom = Atom(
    name: 'CareRecordFormStoreBase.referral',
    context: context,
  );

  @override
  String get referral {
    _$referralAtom.reportRead();
    return super.referral;
  }

  @override
  set referral(String value) {
    _$referralAtom.reportWrite(value, super.referral, () {
      super.referral = value;
    });
  }

  late final _$nextStepAtom = Atom(
    name: 'CareRecordFormStoreBase.nextStep',
    context: context,
  );

  @override
  String get nextStep {
    _$nextStepAtom.reportRead();
    return super.nextStep;
  }

  @override
  set nextStep(String value) {
    _$nextStepAtom.reportWrite(value, super.nextStep, () {
      super.nextStep = value;
    });
  }

  late final _$summaryAtom = Atom(
    name: 'CareRecordFormStoreBase.summary',
    context: context,
  );

  @override
  String get summary {
    _$summaryAtom.reportRead();
    return super.summary;
  }

  @override
  set summary(String value) {
    _$summaryAtom.reportWrite(value, super.summary, () {
      super.summary = value;
    });
  }

  late final _$noteAtom = Atom(
    name: 'CareRecordFormStoreBase.note',
    context: context,
  );

  @override
  String get note {
    _$noteAtom.reportRead();
    return super.note;
  }

  @override
  set note(String value) {
    _$noteAtom.reportWrite(value, super.note, () {
      super.note = value;
    });
  }

  late final _$finishReasonAtom = Atom(
    name: 'CareRecordFormStoreBase.finishReason',
    context: context,
  );

  @override
  FinishReason? get finishReason {
    _$finishReasonAtom.reportRead();
    return super.finishReason;
  }

  @override
  set finishReason(FinishReason? value) {
    _$finishReasonAtom.reportWrite(value, super.finishReason, () {
      super.finishReason = value;
    });
  }

  late final _$isSavingAtom = Atom(
    name: 'CareRecordFormStoreBase.isSaving',
    context: context,
  );

  @override
  bool get isSaving {
    _$isSavingAtom.reportRead();
    return super.isSaving;
  }

  @override
  set isSaving(bool value) {
    _$isSavingAtom.reportWrite(value, super.isSaving, () {
      super.isSaving = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'CareRecordFormStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$submitAsyncAction = AsyncAction(
    'CareRecordFormStoreBase.submit',
    context: context,
  );

  @override
  Future<CareCaseDetail?> submit(
    int personId,
    String token, {
    required List<int> Function(Iterable<String>) tagIdsOf,
  }) {
    return _$submitAsyncAction.run(
      () => super.submit(personId, token, tagIdsOf: tagIdsOf),
    );
  }

  late final _$CareRecordFormStoreBaseActionController = ActionController(
    name: 'CareRecordFormStoreBase',
    context: context,
  );

  @override
  void startWith(CareCase person, {required bool firstRecord}) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.startWith',
    );
    try {
      return super.startWith(person, firstRecord: firstRecord);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStatus(CareRecordStatus value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setStatus',
    );
    try {
      return super.setStatus(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDate(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setDate',
    );
    try {
      return super.setDate(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTime(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setTime',
    );
    try {
      return super.setTime(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleNeed(String need) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.toggleNeed',
    );
    try {
      return super.toggleNeed(need);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSituation(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setSituation',
    );
    try {
      return super.setSituation(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setActionTaken(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setActionTaken',
    );
    try {
      return super.setActionTaken(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReferral(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setReferral',
    );
    try {
      return super.setReferral(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNextStep(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setNextStep',
    );
    try {
      return super.setNextStep(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSummary(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setSummary',
    );
    try {
      return super.setSummary(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNote(String value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setNote',
    );
    try {
      return super.setNote(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFinishReason(FinishReason value) {
    final _$actionInfo = _$CareRecordFormStoreBaseActionController.startAction(
      name: 'CareRecordFormStoreBase.setFinishReason',
    );
    try {
      return super.setFinishReason(value);
    } finally {
      _$CareRecordFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
date: ${date},
time: ${time},
needs: ${needs},
situation: ${situation},
actionTaken: ${actionTaken},
referral: ${referral},
nextStep: ${nextStep},
summary: ${summary},
note: ${note},
finishReason: ${finishReason},
isSaving: ${isSaving},
errorMessage: ${errorMessage},
occurredAt: ${occurredAt},
canSubmit: ${canSubmit}
    ''';
  }
}
