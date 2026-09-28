// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_review_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OrganizationReviewStore on OrganizationReviewStoreBase, Store {
  late final _$organizationAtom = Atom(
    name: 'OrganizationReviewStoreBase.organization',
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

  late final _$stepAtom = Atom(
    name: 'OrganizationReviewStoreBase.step',
    context: context,
  );

  @override
  int get step {
    _$stepAtom.reportRead();
    return super.step;
  }

  @override
  set step(int value) {
    _$stepAtom.reportWrite(value, super.step, () {
      super.step = value;
    });
  }

  late final _$isSubmittingAtom = Atom(
    name: 'OrganizationReviewStoreBase.isSubmitting',
    context: context,
  );

  @override
  bool get isSubmitting {
    _$isSubmittingAtom.reportRead();
    return super.isSubmitting;
  }

  @override
  set isSubmitting(bool value) {
    _$isSubmittingAtom.reportWrite(value, super.isSubmitting, () {
      super.isSubmitting = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'OrganizationReviewStoreBase.errorMessage',
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

  late final _$_reviewAsyncAction = AsyncAction(
    'OrganizationReviewStoreBase._review',
    context: context,
  );

  @override
  Future<bool> _review(Future<Organization> Function() call) {
    return _$_reviewAsyncAction.run(() => super._review(call));
  }

  late final _$OrganizationReviewStoreBaseActionController = ActionController(
    name: 'OrganizationReviewStoreBase',
    context: context,
  );

  @override
  void init(Organization value) {
    final _$actionInfo = _$OrganizationReviewStoreBaseActionController
        .startAction(name: 'OrganizationReviewStoreBase.init');
    try {
      return super.init(value);
    } finally {
      _$OrganizationReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void goTo(int value) {
    final _$actionInfo = _$OrganizationReviewStoreBaseActionController
        .startAction(name: 'OrganizationReviewStoreBase.goTo');
    try {
      return super.goTo(value);
    } finally {
      _$OrganizationReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> approve(String token) {
    final _$actionInfo = _$OrganizationReviewStoreBaseActionController
        .startAction(name: 'OrganizationReviewStoreBase.approve');
    try {
      return super.approve(token);
    } finally {
      _$OrganizationReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> reject(RejectionReason reason, String? note, String token) {
    final _$actionInfo = _$OrganizationReviewStoreBaseActionController
        .startAction(name: 'OrganizationReviewStoreBase.reject');
    try {
      return super.reject(reason, note, token);
    } finally {
      _$OrganizationReviewStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
organization: ${organization},
step: ${step},
isSubmitting: ${isSubmitting},
errorMessage: ${errorMessage}
    ''';
  }
}
