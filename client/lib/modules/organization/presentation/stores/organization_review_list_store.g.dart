// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_review_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OrganizationReviewListStore on OrganizationReviewListStoreBase, Store {
  late final _$filterAtom = Atom(
    name: 'OrganizationReviewListStoreBase.filter',
    context: context,
  );

  @override
  OrganizationStatus? get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(OrganizationStatus? value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$searchAtom = Atom(
    name: 'OrganizationReviewListStoreBase.search',
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

  late final _$organizationsAtom = Atom(
    name: 'OrganizationReviewListStoreBase.organizations',
    context: context,
  );

  @override
  List<Organization> get organizations {
    _$organizationsAtom.reportRead();
    return super.organizations;
  }

  @override
  set organizations(List<Organization> value) {
    _$organizationsAtom.reportWrite(value, super.organizations, () {
      super.organizations = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'OrganizationReviewListStoreBase.isLoading',
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
    name: 'OrganizationReviewListStoreBase.errorMessage',
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
    'OrganizationReviewListStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$OrganizationReviewListStoreBaseActionController =
      ActionController(
        name: 'OrganizationReviewListStoreBase',
        context: context,
      );

  @override
  void setSearch(String value) {
    final _$actionInfo = _$OrganizationReviewListStoreBaseActionController
        .startAction(name: 'OrganizationReviewListStoreBase.setSearch');
    try {
      return super.setSearch(value);
    } finally {
      _$OrganizationReviewListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<void> setFilter(OrganizationStatus? value, String token) {
    final _$actionInfo = _$OrganizationReviewListStoreBaseActionController
        .startAction(name: 'OrganizationReviewListStoreBase.setFilter');
    try {
      return super.setFilter(value, token);
    } finally {
      _$OrganizationReviewListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
filter: ${filter},
search: ${search},
organizations: ${organizations},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
