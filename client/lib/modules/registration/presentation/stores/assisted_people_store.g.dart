// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assisted_people_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AssistedPeopleStore on AssistedPeopleStoreBase, Store {
  late final _$peopleAtom = Atom(
    name: 'AssistedPeopleStoreBase.people',
    context: context,
  );

  @override
  List<AssistedPerson> get people {
    _$peopleAtom.reportRead();
    return super.people;
  }

  @override
  set people(List<AssistedPerson> value) {
    _$peopleAtom.reportWrite(value, super.people, () {
      super.people = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'AssistedPeopleStoreBase.isLoading',
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
    name: 'AssistedPeopleStoreBase.errorMessage',
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

  late final _$deletingIdsAtom = Atom(
    name: 'AssistedPeopleStoreBase.deletingIds',
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

  late final _$loadAsyncAction = AsyncAction(
    'AssistedPeopleStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$deletePersonAsyncAction = AsyncAction(
    'AssistedPeopleStoreBase.deletePerson',
    context: context,
  );

  @override
  Future<bool> deletePerson(int id, String token) {
    return _$deletePersonAsyncAction.run(() => super.deletePerson(id, token));
  }

  @override
  String toString() {
    return '''
people: ${people},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
deletingIds: ${deletingIds}
    ''';
  }
}
