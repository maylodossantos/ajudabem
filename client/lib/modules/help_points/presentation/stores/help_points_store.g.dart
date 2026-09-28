// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_points_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HelpPointsStore on HelpPointsStoreBase, Store {
  Computed<List<HelpPoint>>? _$visiblePointsComputed;

  @override
  List<HelpPoint> get visiblePoints =>
      (_$visiblePointsComputed ??= Computed<List<HelpPoint>>(
        () => super.visiblePoints,
        name: 'HelpPointsStoreBase.visiblePoints',
      )).value;
  Computed<HelpPointOptions>? _$optionsComputed;

  @override
  HelpPointOptions get options =>
      (_$optionsComputed ??= Computed<HelpPointOptions>(
        () => super.options,
        name: 'HelpPointsStoreBase.options',
      )).value;
  Computed<bool>? _$isNearbyActiveComputed;

  @override
  bool get isNearbyActive => (_$isNearbyActiveComputed ??= Computed<bool>(
    () => super.isNearbyActive,
    name: 'HelpPointsStoreBase.isNearbyActive',
  )).value;

  late final _$pointsAtom = Atom(
    name: 'HelpPointsStoreBase.points',
    context: context,
  );

  @override
  List<HelpPoint> get points {
    _$pointsAtom.reportRead();
    return super.points;
  }

  @override
  set points(List<HelpPoint> value) {
    _$pointsAtom.reportWrite(value, super.points, () {
      super.points = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'HelpPointsStoreBase.isLoading',
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
    name: 'HelpPointsStoreBase.errorMessage',
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
    name: 'HelpPointsStoreBase.filter',
    context: context,
  );

  @override
  HelpPointFilter get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(HelpPointFilter value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$originAtom = Atom(
    name: 'HelpPointsStoreBase.origin',
    context: context,
  );

  @override
  GeoPoint? get origin {
    _$originAtom.reportRead();
    return super.origin;
  }

  @override
  set origin(GeoPoint? value) {
    _$originAtom.reportWrite(value, super.origin, () {
      super.origin = value;
    });
  }

  late final _$isLocatingAtom = Atom(
    name: 'HelpPointsStoreBase.isLocating',
    context: context,
  );

  @override
  bool get isLocating {
    _$isLocatingAtom.reportRead();
    return super.isLocating;
  }

  @override
  set isLocating(bool value) {
    _$isLocatingAtom.reportWrite(value, super.isLocating, () {
      super.isLocating = value;
    });
  }

  late final _$locationErrorAtom = Atom(
    name: 'HelpPointsStoreBase.locationError',
    context: context,
  );

  @override
  String? get locationError {
    _$locationErrorAtom.reportRead();
    return super.locationError;
  }

  @override
  set locationError(String? value) {
    _$locationErrorAtom.reportWrite(value, super.locationError, () {
      super.locationError = value;
    });
  }

  late final _$showAsGridAtom = Atom(
    name: 'HelpPointsStoreBase.showAsGrid',
    context: context,
  );

  @override
  bool get showAsGrid {
    _$showAsGridAtom.reportRead();
    return super.showAsGrid;
  }

  @override
  set showAsGrid(bool value) {
    _$showAsGridAtom.reportWrite(value, super.showAsGrid, () {
      super.showAsGrid = value;
    });
  }

  late final _$deletingIdsAtom = Atom(
    name: 'HelpPointsStoreBase.deletingIds',
    context: context,
  );

  @override
  Set<int> get deletingIds {
    _$deletingIdsAtom.reportRead();
    return super.deletingIds;
  }

  @override
  set deletingIds(Set<int> value) {
    _$deletingIdsAtom.reportWrite(value, super.deletingIds, () {
      super.deletingIds = value;
    });
  }

  late final _$nowAtom = Atom(
    name: 'HelpPointsStoreBase.now',
    context: context,
  );

  @override
  DateTime get now {
    _$nowAtom.reportRead();
    return super.now;
  }

  @override
  set now(DateTime value) {
    _$nowAtom.reportWrite(value, super.now, () {
      super.now = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    'HelpPointsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$applyFilterAsyncAction = AsyncAction(
    'HelpPointsStoreBase.applyFilter',
    context: context,
  );

  @override
  Future<void> applyFilter(HelpPointFilter value) {
    return _$applyFilterAsyncAction.run(() => super.applyFilter(value));
  }

  late final _$locateAsyncAction = AsyncAction(
    'HelpPointsStoreBase.locate',
    context: context,
  );

  @override
  Future<void> locate() {
    return _$locateAsyncAction.run(() => super.locate());
  }

  late final _$deleteAsyncAction = AsyncAction(
    'HelpPointsStoreBase.delete',
    context: context,
  );

  @override
  Future<bool> delete(int id, String token) {
    return _$deleteAsyncAction.run(() => super.delete(id, token));
  }

  late final _$HelpPointsStoreBaseActionController = ActionController(
    name: 'HelpPointsStoreBase',
    context: context,
  );

  @override
  Future<void> toggleNearby() {
    final _$actionInfo = _$HelpPointsStoreBaseActionController.startAction(
      name: 'HelpPointsStoreBase.toggleNearby',
    );
    try {
      return super.toggleNearby();
    } finally {
      _$HelpPointsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleTypes(Set<AssistanceType> types) {
    final _$actionInfo = _$HelpPointsStoreBaseActionController.startAction(
      name: 'HelpPointsStoreBase.toggleTypes',
    );
    try {
      return super.toggleTypes(types);
    } finally {
      _$HelpPointsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleOrganizationType(HelpPointOrganizationType type) {
    final _$actionInfo = _$HelpPointsStoreBaseActionController.startAction(
      name: 'HelpPointsStoreBase.toggleOrganizationType',
    );
    try {
      return super.toggleOrganizationType(type);
    } finally {
      _$HelpPointsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleView() {
    final _$actionInfo = _$HelpPointsStoreBaseActionController.startAction(
      name: 'HelpPointsStoreBase.toggleView',
    );
    try {
      return super.toggleView();
    } finally {
      _$HelpPointsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
points: ${points},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filter: ${filter},
origin: ${origin},
isLocating: ${isLocating},
locationError: ${locationError},
showAsGrid: ${showAsGrid},
deletingIds: ${deletingIds},
now: ${now},
visiblePoints: ${visiblePoints},
options: ${options},
isNearbyActive: ${isNearbyActive}
    ''';
  }
}
