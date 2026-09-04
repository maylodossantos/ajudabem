// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileStore on ProfileStoreBase, Store {
  late final _$profileAtom = Atom(
    name: 'ProfileStoreBase.profile',
    context: context,
  );

  @override
  UserProfile? get profile {
    _$profileAtom.reportRead();
    return super.profile;
  }

  @override
  set profile(UserProfile? value) {
    _$profileAtom.reportWrite(value, super.profile, () {
      super.profile = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'ProfileStoreBase.isLoading',
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
    name: 'ProfileStoreBase.errorMessage',
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
    'ProfileStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$ProfileStoreBaseActionController = ActionController(
    name: 'ProfileStoreBase',
    context: context,
  );

  @override
  void clear() {
    final _$actionInfo = _$ProfileStoreBaseActionController.startAction(
      name: 'ProfileStoreBase.clear',
    );
    try {
      return super.clear();
    } finally {
      _$ProfileStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
profile: ${profile},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
