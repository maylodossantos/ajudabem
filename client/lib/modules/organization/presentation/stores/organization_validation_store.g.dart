// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_validation_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OrganizationValidationStore on OrganizationValidationStoreBase, Store {
  late final _$organizationAtom = Atom(
    name: 'OrganizationValidationStoreBase.organization',
    context: context,
  );

  @override
  Organization? get organization {
    _$organizationAtom.reportRead();
    return super.organization;
  }

  @override
  set organization(Organization? value) {
    _$organizationAtom.reportWrite(value, super.organization, () {
      super.organization = value;
    });
  }

  late final _$hasLoadedAtom = Atom(
    name: 'OrganizationValidationStoreBase.hasLoaded',
    context: context,
  );

  @override
  bool get hasLoaded {
    _$hasLoadedAtom.reportRead();
    return super.hasLoaded;
  }

  @override
  set hasLoaded(bool value) {
    _$hasLoadedAtom.reportWrite(value, super.hasLoaded, () {
      super.hasLoaded = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'OrganizationValidationStoreBase.isLoading',
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
    name: 'OrganizationValidationStoreBase.errorMessage',
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
    'OrganizationValidationStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  @override
  String toString() {
    return '''
organization: ${organization},
hasLoaded: ${hasLoaded},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
