// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'impact_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ImpactStore on ImpactStoreBase, Store {
  late final _$platformAtom = Atom(
    name: 'ImpactStoreBase.platform',
    context: context,
  );

  @override
  PlatformImpact? get platform {
    _$platformAtom.reportRead();
    return super.platform;
  }

  @override
  set platform(PlatformImpact? value) {
    _$platformAtom.reportWrite(value, super.platform, () {
      super.platform = value;
    });
  }

  late final _$organizationAtom = Atom(
    name: 'ImpactStoreBase.organization',
    context: context,
  );

  @override
  OrganizationImpact? get organization {
    _$organizationAtom.reportRead();
    return super.organization;
  }

  @override
  set organization(OrganizationImpact? value) {
    _$organizationAtom.reportWrite(value, super.organization, () {
      super.organization = value;
    });
  }

  late final _$loadPlatformAsyncAction = AsyncAction(
    'ImpactStoreBase.loadPlatform',
    context: context,
  );

  @override
  Future<void> loadPlatform(String token) {
    return _$loadPlatformAsyncAction.run(() => super.loadPlatform(token));
  }

  late final _$loadOrganizationAsyncAction = AsyncAction(
    'ImpactStoreBase.loadOrganization',
    context: context,
  );

  @override
  Future<void> loadOrganization(String token) {
    return _$loadOrganizationAsyncAction.run(
      () => super.loadOrganization(token),
    );
  }

  @override
  String toString() {
    return '''
platform: ${platform},
organization: ${organization}
    ''';
  }
}
