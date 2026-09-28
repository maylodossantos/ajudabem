// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_case_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CareCaseStore on CareCaseStoreBase, Store {
  late final _$detailAtom = Atom(
    name: 'CareCaseStoreBase.detail',
    context: context,
  );

  @override
  CareCaseDetail? get detail {
    _$detailAtom.reportRead();
    return super.detail;
  }

  @override
  set detail(CareCaseDetail? value) {
    _$detailAtom.reportWrite(value, super.detail, () {
      super.detail = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'CareCaseStoreBase.isLoading',
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
    name: 'CareCaseStoreBase.isAssuming',
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
    name: 'CareCaseStoreBase.errorMessage',
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
    'CareCaseStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(int personId, String token) {
    return _$loadAsyncAction.run(() => super.load(personId, token));
  }

  late final _$assumeAsyncAction = AsyncAction(
    'CareCaseStoreBase.assume',
    context: context,
  );

  @override
  Future<bool> assume(String token) {
    return _$assumeAsyncAction.run(() => super.assume(token));
  }

  late final _$CareCaseStoreBaseActionController = ActionController(
    name: 'CareCaseStoreBase',
    context: context,
  );

  @override
  void show(CareCaseDetail value) {
    final _$actionInfo = _$CareCaseStoreBaseActionController.startAction(
      name: 'CareCaseStoreBase.show',
    );
    try {
      return super.show(value);
    } finally {
      _$CareCaseStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
detail: ${detail},
isLoading: ${isLoading},
isAssuming: ${isAssuming},
errorMessage: ${errorMessage}
    ''';
  }
}
