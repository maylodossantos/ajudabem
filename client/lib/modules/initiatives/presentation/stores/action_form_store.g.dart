// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ActionFormStore on ActionFormStoreBase, Store {
  Computed<DateTime?>? _$actionDateComputed;

  @override
  DateTime? get actionDate => (_$actionDateComputed ??= Computed<DateTime?>(
    () => super.actionDate,
    name: 'ActionFormStoreBase.actionDate',
  )).value;
  Computed<bool>? _$timesValidComputed;

  @override
  bool get timesValid => (_$timesValidComputed ??= Computed<bool>(
    () => super.timesValid,
    name: 'ActionFormStoreBase.timesValid',
  )).value;
  Computed<int?>? _$volunteersNeededComputed;

  @override
  int? get volunteersNeeded => (_$volunteersNeededComputed ??= Computed<int?>(
    () => super.volunteersNeeded,
    name: 'ActionFormStoreBase.volunteersNeeded',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'ActionFormStoreBase.canSubmit',
  )).value;

  late final _$actionIdAtom = Atom(
    name: 'ActionFormStoreBase.actionId',
    context: context,
  );

  @override
  int? get actionId {
    _$actionIdAtom.reportRead();
    return super.actionId;
  }

  @override
  set actionId(int? value) {
    _$actionIdAtom.reportWrite(value, super.actionId, () {
      super.actionId = value;
    });
  }

  late final _$titleAtom = Atom(
    name: 'ActionFormStoreBase.title',
    context: context,
  );

  @override
  String get title {
    _$titleAtom.reportRead();
    return super.title;
  }

  @override
  set title(String value) {
    _$titleAtom.reportWrite(value, super.title, () {
      super.title = value;
    });
  }

  late final _$dateAtom = Atom(
    name: 'ActionFormStoreBase.date',
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

  late final _$startTimeAtom = Atom(
    name: 'ActionFormStoreBase.startTime',
    context: context,
  );

  @override
  String get startTime {
    _$startTimeAtom.reportRead();
    return super.startTime;
  }

  @override
  set startTime(String value) {
    _$startTimeAtom.reportWrite(value, super.startTime, () {
      super.startTime = value;
    });
  }

  late final _$endTimeAtom = Atom(
    name: 'ActionFormStoreBase.endTime',
    context: context,
  );

  @override
  String get endTime {
    _$endTimeAtom.reportRead();
    return super.endTime;
  }

  @override
  set endTime(String value) {
    _$endTimeAtom.reportWrite(value, super.endTime, () {
      super.endTime = value;
    });
  }

  late final _$volunteersAtom = Atom(
    name: 'ActionFormStoreBase.volunteers',
    context: context,
  );

  @override
  String get volunteers {
    _$volunteersAtom.reportRead();
    return super.volunteers;
  }

  @override
  set volunteers(String value) {
    _$volunteersAtom.reportWrite(value, super.volunteers, () {
      super.volunteers = value;
    });
  }

  late final _$streetAtom = Atom(
    name: 'ActionFormStoreBase.street',
    context: context,
  );

  @override
  String get street {
    _$streetAtom.reportRead();
    return super.street;
  }

  @override
  set street(String value) {
    _$streetAtom.reportWrite(value, super.street, () {
      super.street = value;
    });
  }

  late final _$numberAtom = Atom(
    name: 'ActionFormStoreBase.number',
    context: context,
  );

  @override
  String get number {
    _$numberAtom.reportRead();
    return super.number;
  }

  @override
  set number(String value) {
    _$numberAtom.reportWrite(value, super.number, () {
      super.number = value;
    });
  }

  late final _$cityAtom = Atom(
    name: 'ActionFormStoreBase.city',
    context: context,
  );

  @override
  String get city {
    _$cityAtom.reportRead();
    return super.city;
  }

  @override
  set city(String value) {
    _$cityAtom.reportWrite(value, super.city, () {
      super.city = value;
    });
  }

  late final _$stateAtom = Atom(
    name: 'ActionFormStoreBase.state',
    context: context,
  );

  @override
  String get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(String value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$zipCodeAtom = Atom(
    name: 'ActionFormStoreBase.zipCode',
    context: context,
  );

  @override
  String get zipCode {
    _$zipCodeAtom.reportRead();
    return super.zipCode;
  }

  @override
  set zipCode(String value) {
    _$zipCodeAtom.reportWrite(value, super.zipCode, () {
      super.zipCode = value;
    });
  }

  late final _$descriptionAtom = Atom(
    name: 'ActionFormStoreBase.description',
    context: context,
  );

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  late final _$tasksAtom = Atom(
    name: 'ActionFormStoreBase.tasks',
    context: context,
  );

  @override
  String get tasks {
    _$tasksAtom.reportRead();
    return super.tasks;
  }

  @override
  set tasks(String value) {
    _$tasksAtom.reportWrite(value, super.tasks, () {
      super.tasks = value;
    });
  }

  late final _$requirementsAtom = Atom(
    name: 'ActionFormStoreBase.requirements',
    context: context,
  );

  @override
  String get requirements {
    _$requirementsAtom.reportRead();
    return super.requirements;
  }

  @override
  set requirements(String value) {
    _$requirementsAtom.reportWrite(value, super.requirements, () {
      super.requirements = value;
    });
  }

  late final _$notesAtom = Atom(
    name: 'ActionFormStoreBase.notes',
    context: context,
  );

  @override
  String get notes {
    _$notesAtom.reportRead();
    return super.notes;
  }

  @override
  set notes(String value) {
    _$notesAtom.reportWrite(value, super.notes, () {
      super.notes = value;
    });
  }

  late final _$isSavingAtom = Atom(
    name: 'ActionFormStoreBase.isSaving',
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
    name: 'ActionFormStoreBase.errorMessage',
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
    'ActionFormStoreBase.submit',
    context: context,
  );

  @override
  Future<VolunteerAction?> submit(String token) {
    return _$submitAsyncAction.run(() => super.submit(token));
  }

  late final _$ActionFormStoreBaseActionController = ActionController(
    name: 'ActionFormStoreBase',
    context: context,
  );

  @override
  void populate(VolunteerAction action) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.populate',
    );
    try {
      return super.populate(action);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTitle(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setTitle',
    );
    try {
      return super.setTitle(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDate(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setDate',
    );
    try {
      return super.setDate(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStartTime(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setStartTime',
    );
    try {
      return super.setStartTime(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEndTime(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setEndTime',
    );
    try {
      return super.setEndTime(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVolunteers(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setVolunteers',
    );
    try {
      return super.setVolunteers(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStreet(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setStreet',
    );
    try {
      return super.setStreet(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNumber(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setNumber',
    );
    try {
      return super.setNumber(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCity(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setCity',
    );
    try {
      return super.setCity(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setState(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setState',
    );
    try {
      return super.setState(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setZipCode(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setZipCode',
    );
    try {
      return super.setZipCode(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDescription(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setDescription',
    );
    try {
      return super.setDescription(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTasks(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setTasks',
    );
    try {
      return super.setTasks(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRequirements(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setRequirements',
    );
    try {
      return super.setRequirements(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotes(String value) {
    final _$actionInfo = _$ActionFormStoreBaseActionController.startAction(
      name: 'ActionFormStoreBase.setNotes',
    );
    try {
      return super.setNotes(value);
    } finally {
      _$ActionFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
actionId: ${actionId},
title: ${title},
date: ${date},
startTime: ${startTime},
endTime: ${endTime},
volunteers: ${volunteers},
street: ${street},
number: ${number},
city: ${city},
state: ${state},
zipCode: ${zipCode},
description: ${description},
tasks: ${tasks},
requirements: ${requirements},
notes: ${notes},
isSaving: ${isSaving},
errorMessage: ${errorMessage},
actionDate: ${actionDate},
timesValid: ${timesValid},
volunteersNeeded: ${volunteersNeeded},
canSubmit: ${canSubmit}
    ''';
  }
}
