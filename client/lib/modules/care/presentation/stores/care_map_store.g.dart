// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_map_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CareMapStore on CareMapStoreBase, Store {
  Computed<List<CareCase>>? _$visibleComputed;

  @override
  List<CareCase> get visible => (_$visibleComputed ??= Computed<List<CareCase>>(
    () => super.visible,
    name: 'CareMapStoreBase.visible',
  )).value;
  Computed<List<CareFocus>>? _$fociComputed;

  @override
  List<CareFocus> get foci => (_$fociComputed ??= Computed<List<CareFocus>>(
    () => super.foci,
    name: 'CareMapStoreBase.foci',
  )).value;

  late final _$casesAtom = Atom(
    name: 'CareMapStoreBase.cases',
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

  late final _$layerAtom = Atom(
    name: 'CareMapStoreBase.layer',
    context: context,
  );

  @override
  MapLayer get layer {
    _$layerAtom.reportRead();
    return super.layer;
  }

  @override
  set layer(MapLayer value) {
    _$layerAtom.reportWrite(value, super.layer, () {
      super.layer = value;
    });
  }

  late final _$modeAtom = Atom(name: 'CareMapStoreBase.mode', context: context);

  @override
  MapMode get mode {
    _$modeAtom.reportRead();
    return super.mode;
  }

  @override
  set mode(MapMode value) {
    _$modeAtom.reportWrite(value, super.mode, () {
      super.mode = value;
    });
  }

  late final _$selectedAtom = Atom(
    name: 'CareMapStoreBase.selected',
    context: context,
  );

  @override
  CareCase? get selected {
    _$selectedAtom.reportRead();
    return super.selected;
  }

  @override
  set selected(CareCase? value) {
    _$selectedAtom.reportWrite(value, super.selected, () {
      super.selected = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'CareMapStoreBase.isLoading',
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

  late final _$isAssumingAtom = Atom(
    name: 'CareMapStoreBase.isAssuming',
    context: context,
  );

  @override
  bool get isAssuming {
    _$isAssumingAtom.reportRead();
    return super.isAssuming;
  }

  @override
  set isAssuming(bool value) {
    _$isAssumingAtom.reportWrite(value, super.isAssuming, () {
      super.isAssuming = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'CareMapStoreBase.errorMessage',
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
    'CareMapStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$assumeSelectedAsyncAction = AsyncAction(
    'CareMapStoreBase.assumeSelected',
    context: context,
  );

  @override
  Future<bool> assumeSelected(String token) {
    return _$assumeSelectedAsyncAction.run(() => super.assumeSelected(token));
  }

  late final _$CareMapStoreBaseActionController = ActionController(
    name: 'CareMapStoreBase',
    context: context,
  );

  @override
  void setLayer(MapLayer value) {
    final _$actionInfo = _$CareMapStoreBaseActionController.startAction(
      name: 'CareMapStoreBase.setLayer',
    );
    try {
      return super.setLayer(value);
    } finally {
      _$CareMapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleMode() {
    final _$actionInfo = _$CareMapStoreBaseActionController.startAction(
      name: 'CareMapStoreBase.toggleMode',
    );
    try {
      return super.toggleMode();
    } finally {
      _$CareMapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showPeople() {
    final _$actionInfo = _$CareMapStoreBaseActionController.startAction(
      name: 'CareMapStoreBase.showPeople',
    );
    try {
      return super.showPeople();
    } finally {
      _$CareMapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select(CareCase? person) {
    final _$actionInfo = _$CareMapStoreBaseActionController.startAction(
      name: 'CareMapStoreBase.select',
    );
    try {
      return super.select(person);
    } finally {
      _$CareMapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cases: ${cases},
layer: ${layer},
mode: ${mode},
selected: ${selected},
isLoading: ${isLoading},
isAssuming: ${isAssuming},
errorMessage: ${errorMessage},
visible: ${visible},
foci: ${foci}
    ''';
  }
}
