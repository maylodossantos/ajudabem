// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_point_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HelpPointFormStore on HelpPointFormStoreBase, Store {
  Computed<bool>? _$isEditingComputed;

  @override
  bool get isEditing => (_$isEditingComputed ??= Computed<bool>(
    () => super.isEditing,
    name: 'HelpPointFormStoreBase.isEditing',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'HelpPointFormStoreBase.canSubmit',
  )).value;

  late final _$editingIdAtom = Atom(
    name: 'HelpPointFormStoreBase.editingId',
    context: context,
  );

  @override
  int? get editingId {
    _$editingIdAtom.reportRead();
    return super.editingId;
  }

  @override
  set editingId(int? value) {
    _$editingIdAtom.reportWrite(value, super.editingId, () {
      super.editingId = value;
    });
  }

  late final _$nameAtom = Atom(
    name: 'HelpPointFormStoreBase.name',
    context: context,
  );

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$descriptionAtom = Atom(
    name: 'HelpPointFormStoreBase.description',
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

  late final _$organizationTypeAtom = Atom(
    name: 'HelpPointFormStoreBase.organizationType',
    context: context,
  );

  @override
  HelpPointOrganizationType? get organizationType {
    _$organizationTypeAtom.reportRead();
    return super.organizationType;
  }

  @override
  set organizationType(HelpPointOrganizationType? value) {
    _$organizationTypeAtom.reportWrite(value, super.organizationType, () {
      super.organizationType = value;
    });
  }

  late final _$servicesAtom = Atom(
    name: 'HelpPointFormStoreBase.services',
    context: context,
  );

  @override
  ObservableSet<AssistanceType> get services {
    _$servicesAtom.reportRead();
    return super.services;
  }

  @override
  set services(ObservableSet<AssistanceType> value) {
    _$servicesAtom.reportWrite(value, super.services, () {
      super.services = value;
    });
  }

  late final _$streetAtom = Atom(
    name: 'HelpPointFormStoreBase.street',
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
    name: 'HelpPointFormStoreBase.number',
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

  late final _$neighborhoodAtom = Atom(
    name: 'HelpPointFormStoreBase.neighborhood',
    context: context,
  );

  @override
  String get neighborhood {
    _$neighborhoodAtom.reportRead();
    return super.neighborhood;
  }

  @override
  set neighborhood(String value) {
    _$neighborhoodAtom.reportWrite(value, super.neighborhood, () {
      super.neighborhood = value;
    });
  }

  late final _$cityAtom = Atom(
    name: 'HelpPointFormStoreBase.city',
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
    name: 'HelpPointFormStoreBase.state',
    context: context,
  );

  @override
  String? get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(String? value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$zipCodeAtom = Atom(
    name: 'HelpPointFormStoreBase.zipCode',
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

  late final _$phoneAtom = Atom(
    name: 'HelpPointFormStoreBase.phone',
    context: context,
  );

  @override
  String get phone {
    _$phoneAtom.reportRead();
    return super.phone;
  }

  @override
  set phone(String value) {
    _$phoneAtom.reportWrite(value, super.phone, () {
      super.phone = value;
    });
  }

  late final _$whatsappAtom = Atom(
    name: 'HelpPointFormStoreBase.whatsapp',
    context: context,
  );

  @override
  String get whatsapp {
    _$whatsappAtom.reportRead();
    return super.whatsapp;
  }

  @override
  set whatsapp(String value) {
    _$whatsappAtom.reportWrite(value, super.whatsapp, () {
      super.whatsapp = value;
    });
  }

  late final _$emailAtom = Atom(
    name: 'HelpPointFormStoreBase.email',
    context: context,
  );

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$responsibleAtom = Atom(
    name: 'HelpPointFormStoreBase.responsible',
    context: context,
  );

  @override
  String get responsible {
    _$responsibleAtom.reportRead();
    return super.responsible;
  }

  @override
  set responsible(String value) {
    _$responsibleAtom.reportWrite(value, super.responsible, () {
      super.responsible = value;
    });
  }

  late final _$hoursAtom = Atom(
    name: 'HelpPointFormStoreBase.hours',
    context: context,
  );

  @override
  ObservableMap<int, OpeningHours> get hours {
    _$hoursAtom.reportRead();
    return super.hours;
  }

  @override
  set hours(ObservableMap<int, OpeningHours> value) {
    _$hoursAtom.reportWrite(value, super.hours, () {
      super.hours = value;
    });
  }

  late final _$scheduleNoteAtom = Atom(
    name: 'HelpPointFormStoreBase.scheduleNote',
    context: context,
  );

  @override
  String get scheduleNote {
    _$scheduleNoteAtom.reportRead();
    return super.scheduleNote;
  }

  @override
  set scheduleNote(String value) {
    _$scheduleNoteAtom.reportWrite(value, super.scheduleNote, () {
      super.scheduleNote = value;
    });
  }

  late final _$notesAtom = Atom(
    name: 'HelpPointFormStoreBase.notes',
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

  late final _$isLoadingAtom = Atom(
    name: 'HelpPointFormStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'HelpPointFormStoreBase.errorMessage',
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

  late final _$savedAtom = Atom(
    name: 'HelpPointFormStoreBase.saved',
    context: context,
  );

  @override
  HelpPoint? get saved {
    _$savedAtom.reportRead();
    return super.saved;
  }

  @override
  set saved(HelpPoint? value) {
    _$savedAtom.reportWrite(value, super.saved, () {
      super.saved = value;
    });
  }

  late final _$submitAsyncAction = AsyncAction(
    'HelpPointFormStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit(String token) {
    return _$submitAsyncAction.run(() => super.submit(token));
  }

  late final _$HelpPointFormStoreBaseActionController = ActionController(
    name: 'HelpPointFormStoreBase',
    context: context,
  );

  @override
  void populate(HelpPoint point) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.populate',
    );
    try {
      return super.populate(point);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setName(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setName',
    );
    try {
      return super.setName(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDescription(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setDescription',
    );
    try {
      return super.setDescription(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOrganizationType(HelpPointOrganizationType value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setOrganizationType',
    );
    try {
      return super.setOrganizationType(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleService(AssistanceType type) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.toggleService',
    );
    try {
      return super.toggleService(type);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStreet(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setStreet',
    );
    try {
      return super.setStreet(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNumber(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setNumber',
    );
    try {
      return super.setNumber(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNeighborhood(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setNeighborhood',
    );
    try {
      return super.setNeighborhood(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCity(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setCity',
    );
    try {
      return super.setCity(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setState(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setState',
    );
    try {
      return super.setState(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setZipCode(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setZipCode',
    );
    try {
      return super.setZipCode(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPhone(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setPhone',
    );
    try {
      return super.setPhone(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWhatsapp(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setWhatsapp',
    );
    try {
      return super.setWhatsapp(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setEmail',
    );
    try {
      return super.setEmail(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setResponsible(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setResponsible',
    );
    try {
      return super.setResponsible(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setScheduleNote(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setScheduleNote',
    );
    try {
      return super.setScheduleNote(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotes(String value) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setNotes',
    );
    try {
      return super.setNotes(value);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDayOpen(int weekday, bool open) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setDayOpen',
    );
    try {
      return super.setDayOpen(weekday, open);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDayAllDay(int weekday, bool allDay) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setDayAllDay',
    );
    try {
      return super.setDayAllDay(weekday, allDay);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDayTimes(int weekday, {int? opensAt, int? closesAt}) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.setDayTimes',
    );
    try {
      return super.setDayTimes(weekday, opensAt: opensAt, closesAt: closesAt);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void applyToAllDays(int weekday) {
    final _$actionInfo = _$HelpPointFormStoreBaseActionController.startAction(
      name: 'HelpPointFormStoreBase.applyToAllDays',
    );
    try {
      return super.applyToAllDays(weekday);
    } finally {
      _$HelpPointFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
editingId: ${editingId},
name: ${name},
description: ${description},
organizationType: ${organizationType},
services: ${services},
street: ${street},
number: ${number},
neighborhood: ${neighborhood},
city: ${city},
state: ${state},
zipCode: ${zipCode},
phone: ${phone},
whatsapp: ${whatsapp},
email: ${email},
responsible: ${responsible},
hours: ${hours},
scheduleNote: ${scheduleNote},
notes: ${notes},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
saved: ${saved},
isEditing: ${isEditing},
canSubmit: ${canSubmit}
    ''';
  }
}
