// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_stores.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ActionDetailStore on ActionDetailStoreBase, Store {
  late final _$currentAtom = Atom(
    name: 'ActionDetailStoreBase.current',
    context: context,
  );

  @override
  VolunteerAction? get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(VolunteerAction? value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'ActionDetailStoreBase.isLoading',
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

  late final _$isBusyAtom = Atom(
    name: 'ActionDetailStoreBase.isBusy',
    context: context,
  );

  @override
  bool get isBusy {
    _$isBusyAtom.reportRead();
    return super.isBusy;
  }

  @override
  set isBusy(bool value) {
    _$isBusyAtom.reportWrite(value, super.isBusy, () {
      super.isBusy = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'ActionDetailStoreBase.errorMessage',
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

  late final _$loadAsyncAction = AsyncAction(
    'ActionDetailStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(int id, String token) {
    return _$loadAsyncAction.run(() => super.load(id, token));
  }

  @override
  String toString() {
    return '''
current: ${current},
isLoading: ${isLoading},
isBusy: ${isBusy},
errorMessage: ${errorMessage}
    ''';
  }
}

mixin _$VolunteersStore on VolunteersStoreBase, Store {
  Computed<int>? _$acceptedCountComputed;

  @override
  int get acceptedCount => (_$acceptedCountComputed ??= Computed<int>(
    () => super.acceptedCount,
    name: 'VolunteersStoreBase.acceptedCount',
  )).value;

  late final _$currentAtom = Atom(
    name: 'VolunteersStoreBase.current',
    context: context,
  );

  @override
  VolunteerAction? get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(VolunteerAction? value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$volunteersAtom = Atom(
    name: 'VolunteersStoreBase.volunteers',
    context: context,
  );

  @override
  List<VolunteerApplication> get volunteers {
    _$volunteersAtom.reportRead();
    return super.volunteers;
  }

  @override
  set volunteers(List<VolunteerApplication> value) {
    _$volunteersAtom.reportWrite(value, super.volunteers, () {
      super.volunteers = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'VolunteersStoreBase.isLoading',
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

  late final _$acceptingIdsAtom = Atom(
    name: 'VolunteersStoreBase.acceptingIds',
    context: context,
  );

  @override
  Set<int> get acceptingIds {
    _$acceptingIdsAtom.reportRead();
    return super.acceptingIds;
  }

  @override
  set acceptingIds(Set<int> value) {
    _$acceptingIdsAtom.reportWrite(value, super.acceptingIds, () {
      super.acceptingIds = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'VolunteersStoreBase.errorMessage',
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

  late final _$loadAsyncAction = AsyncAction(
    'VolunteersStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(int actionId, String token) {
    return _$loadAsyncAction.run(() => super.load(actionId, token));
  }

  late final _$acceptAsyncAction = AsyncAction(
    'VolunteersStoreBase.accept',
    context: context,
  );

  @override
  Future<bool> accept(VolunteerApplication application, String token) {
    return _$acceptAsyncAction.run(() => super.accept(application, token));
  }

  @override
  String toString() {
    return '''
current: ${current},
volunteers: ${volunteers},
isLoading: ${isLoading},
acceptingIds: ${acceptingIds},
errorMessage: ${errorMessage},
acceptedCount: ${acceptedCount}
    ''';
  }
}

mixin _$OpenActionsStore on OpenActionsStoreBase, Store {
  Computed<List<VolunteerAction>>? _$visibleActionsComputed;

  @override
  List<VolunteerAction> get visibleActions =>
      (_$visibleActionsComputed ??= Computed<List<VolunteerAction>>(
        () => super.visibleActions,
        name: 'OpenActionsStoreBase.visibleActions',
      )).value;

  late final _$actionsAtom = Atom(
    name: 'OpenActionsStoreBase.actions',
    context: context,
  );

  @override
  List<VolunteerAction> get actions {
    _$actionsAtom.reportRead();
    return super.actions;
  }

  @override
  set actions(List<VolunteerAction> value) {
    _$actionsAtom.reportWrite(value, super.actions, () {
      super.actions = value;
    });
  }

  late final _$searchAtom = Atom(
    name: 'OpenActionsStoreBase.search',
    context: context,
  );

  @override
  String get search {
    _$searchAtom.reportRead();
    return super.search;
  }

  @override
  set search(String value) {
    _$searchAtom.reportWrite(value, super.search, () {
      super.search = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'OpenActionsStoreBase.isLoading',
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

  late final _$applyingIdsAtom = Atom(
    name: 'OpenActionsStoreBase.applyingIds',
    context: context,
  );

  @override
  Set<int> get applyingIds {
    _$applyingIdsAtom.reportRead();
    return super.applyingIds;
  }

  @override
  set applyingIds(Set<int> value) {
    _$applyingIdsAtom.reportWrite(value, super.applyingIds, () {
      super.applyingIds = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'OpenActionsStoreBase.errorMessage',
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

  late final _$loadAsyncAction = AsyncAction(
    'OpenActionsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$applyAsyncAction = AsyncAction(
    'OpenActionsStoreBase.apply',
    context: context,
  );

  @override
  Future<bool> apply(VolunteerAction action, String token) {
    return _$applyAsyncAction.run(() => super.apply(action, token));
  }

  late final _$OpenActionsStoreBaseActionController = ActionController(
    name: 'OpenActionsStoreBase',
    context: context,
  );

  @override
  void setSearch(String value) {
    final _$actionInfo = _$OpenActionsStoreBaseActionController.startAction(
      name: 'OpenActionsStoreBase.setSearch',
    );
    try {
      return super.setSearch(value);
    } finally {
      _$OpenActionsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void replace(VolunteerAction updated) {
    final _$actionInfo = _$OpenActionsStoreBaseActionController.startAction(
      name: 'OpenActionsStoreBase.replace',
    );
    try {
      return super.replace(updated);
    } finally {
      _$OpenActionsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
actions: ${actions},
search: ${search},
isLoading: ${isLoading},
applyingIds: ${applyingIds},
errorMessage: ${errorMessage},
visibleActions: ${visibleActions}
    ''';
  }
}
