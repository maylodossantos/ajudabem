// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiatives_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$InitiativesStore on InitiativesStoreBase, Store {
  Computed<bool>? _$isEmptyComputed;

  @override
  bool get isEmpty => (_$isEmptyComputed ??= Computed<bool>(
    () => super.isEmpty,
    name: 'InitiativesStoreBase.isEmpty',
  )).value;
  Computed<List<Campaign>>? _$visibleCampaignsComputed;

  @override
  List<Campaign> get visibleCampaigns =>
      (_$visibleCampaignsComputed ??= Computed<List<Campaign>>(
        () => super.visibleCampaigns,
        name: 'InitiativesStoreBase.visibleCampaigns',
      )).value;
  Computed<List<VolunteerAction>>? _$visibleActionsComputed;

  @override
  List<VolunteerAction> get visibleActions =>
      (_$visibleActionsComputed ??= Computed<List<VolunteerAction>>(
        () => super.visibleActions,
        name: 'InitiativesStoreBase.visibleActions',
      )).value;

  late final _$campaignsAtom = Atom(
    name: 'InitiativesStoreBase.campaigns',
    context: context,
  );

  @override
  List<Campaign> get campaigns {
    _$campaignsAtom.reportRead();
    return super.campaigns;
  }

  @override
  set campaigns(List<Campaign> value) {
    _$campaignsAtom.reportWrite(value, super.campaigns, () {
      super.campaigns = value;
    });
  }

  late final _$actionsAtom = Atom(
    name: 'InitiativesStoreBase.actions',
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

  late final _$tabAtom = Atom(
    name: 'InitiativesStoreBase.tab',
    context: context,
  );

  @override
  InitiativeTab get tab {
    _$tabAtom.reportRead();
    return super.tab;
  }

  @override
  set tab(InitiativeTab value) {
    _$tabAtom.reportWrite(value, super.tab, () {
      super.tab = value;
    });
  }

  late final _$searchAtom = Atom(
    name: 'InitiativesStoreBase.search',
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
    name: 'InitiativesStoreBase.isLoading',
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

  late final _$loadedAtom = Atom(
    name: 'InitiativesStoreBase.loaded',
    context: context,
  );

  @override
  bool get loaded {
    _$loadedAtom.reportRead();
    return super.loaded;
  }

  @override
  set loaded(bool value) {
    _$loadedAtom.reportWrite(value, super.loaded, () {
      super.loaded = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'InitiativesStoreBase.errorMessage',
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
    'InitiativesStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$InitiativesStoreBaseActionController = ActionController(
    name: 'InitiativesStoreBase',
    context: context,
  );

  @override
  void setTab(InitiativeTab value) {
    final _$actionInfo = _$InitiativesStoreBaseActionController.startAction(
      name: 'InitiativesStoreBase.setTab',
    );
    try {
      return super.setTab(value);
    } finally {
      _$InitiativesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearch(String value) {
    final _$actionInfo = _$InitiativesStoreBaseActionController.startAction(
      name: 'InitiativesStoreBase.setSearch',
    );
    try {
      return super.setSearch(value);
    } finally {
      _$InitiativesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
campaigns: ${campaigns},
actions: ${actions},
tab: ${tab},
search: ${search},
isLoading: ${isLoading},
loaded: ${loaded},
errorMessage: ${errorMessage},
isEmpty: ${isEmpty},
visibleCampaigns: ${visibleCampaigns},
visibleActions: ${visibleActions}
    ''';
  }
}
