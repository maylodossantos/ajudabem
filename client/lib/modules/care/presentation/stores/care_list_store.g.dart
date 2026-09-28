// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CareListStore on CareListStoreBase, Store {
  Computed<List<CareCase>>? _$visibleCasesComputed;

  @override
  List<CareCase> get visibleCases =>
      (_$visibleCasesComputed ??= Computed<List<CareCase>>(
        () => super.visibleCases,
        name: 'CareListStoreBase.visibleCases',
      )).value;
  Computed<CareOptions>? _$optionsComputed;

  @override
  CareOptions get options => (_$optionsComputed ??= Computed<CareOptions>(
    () => super.options,
    name: 'CareListStoreBase.options',
  )).value;

  late final _$modeAtom = Atom(
    name: 'CareListStoreBase.mode',
    context: context,
  );

  @override
  CareListMode get mode {
    _$modeAtom.reportRead();
    return super.mode;
  }

  @override
  set mode(CareListMode value) {
    _$modeAtom.reportWrite(value, super.mode, () {
      super.mode = value;
    });
  }

  late final _$casesAtom = Atom(
    name: 'CareListStoreBase.cases',
    context: context,
  );

  @override
  List<CareCase> get cases {
    _$casesAtom.reportRead();
    return super.cases;
  }

  @override
  set cases(List<CareCase> value) {
    _$casesAtom.reportWrite(value, super.cases, () {
      super.cases = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'CareListStoreBase.isLoading',
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
    name: 'CareListStoreBase.errorMessage',
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

  late final _$filterAtom = Atom(
    name: 'CareListStoreBase.filter',
    context: context,
  );

  @override
  CareFilter get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(CareFilter value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$assumingIdsAtom = Atom(
    name: 'CareListStoreBase.assumingIds',
    context: context,
  );

  @override
  Set<int> get assumingIds {
    _$assumingIdsAtom.reportRead();
    return super.assumingIds;
  }

  @override
  set assumingIds(Set<int> value) {
    _$assumingIdsAtom.reportWrite(value, super.assumingIds, () {
      super.assumingIds = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    'CareListStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token, {CareListMode? mode}) {
    return _$loadAsyncAction.run(() => super.load(token, mode: mode));
  }

  late final _$assumeAsyncAction = AsyncAction(
    'CareListStoreBase.assume',
    context: context,
  );

  @override
  Future<bool> assume(int id, String token) {
    return _$assumeAsyncAction.run(() => super.assume(id, token));
  }

  late final _$CareListStoreBaseActionController = ActionController(
    name: 'CareListStoreBase',
    context: context,
  );

  @override
  void setSearch(String value) {
    final _$actionInfo = _$CareListStoreBaseActionController.startAction(
      name: 'CareListStoreBase.setSearch',
    );
    try {
      return super.setSearch(value);
    } finally {
      _$CareListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void applyFilter(CareFilter value) {
    final _$actionInfo = _$CareListStoreBaseActionController.startAction(
      name: 'CareListStoreBase.applyFilter',
    );
    try {
      return super.applyFilter(value);
    } finally {
      _$CareListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
mode: ${mode},
cases: ${cases},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filter: ${filter},
assumingIds: ${assumingIds},
visibleCases: ${visibleCases},
options: ${options}
    ''';
  }
}
