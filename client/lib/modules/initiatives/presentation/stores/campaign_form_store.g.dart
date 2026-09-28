// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CampaignFormStore on CampaignFormStoreBase, Store {
  Computed<DateTime?>? _$deadlineDateComputed;

  @override
  DateTime? get deadlineDate => (_$deadlineDateComputed ??= Computed<DateTime?>(
    () => super.deadlineDate,
    name: 'CampaignFormStoreBase.deadlineDate',
  )).value;
  Computed<bool>? _$deadlineValidComputed;

  @override
  bool get deadlineValid => (_$deadlineValidComputed ??= Computed<bool>(
    () => super.deadlineValid,
    name: 'CampaignFormStoreBase.deadlineValid',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'CampaignFormStoreBase.canSubmit',
  )).value;

  late final _$campaignIdAtom = Atom(
    name: 'CampaignFormStoreBase.campaignId',
    context: context,
  );

  @override
  int? get campaignId {
    _$campaignIdAtom.reportRead();
    return super.campaignId;
  }

  @override
  set campaignId(int? value) {
    _$campaignIdAtom.reportWrite(value, super.campaignId, () {
      super.campaignId = value;
    });
  }

  late final _$titleAtom = Atom(
    name: 'CampaignFormStoreBase.title',
    context: context,
  );

  @override
  String get title {
    _$titleAtom.reportRead();
    return super.title;
  }

  @override
  set title(String value) {
    _$titleAtom.reportWrite(value, super.title, () {
      super.title = value;
    });
  }

  late final _$donationInfoAtom = Atom(
    name: 'CampaignFormStoreBase.donationInfo',
    context: context,
  );

  @override
  String get donationInfo {
    _$donationInfoAtom.reportRead();
    return super.donationInfo;
  }

  @override
  set donationInfo(String value) {
    _$donationInfoAtom.reportWrite(value, super.donationInfo, () {
      super.donationInfo = value;
    });
  }

  late final _$subtitleAtom = Atom(
    name: 'CampaignFormStoreBase.subtitle',
    context: context,
  );

  @override
  String get subtitle {
    _$subtitleAtom.reportRead();
    return super.subtitle;
  }

  @override
  set subtitle(String value) {
    _$subtitleAtom.reportWrite(value, super.subtitle, () {
      super.subtitle = value;
    });
  }

  late final _$descriptionAtom = Atom(
    name: 'CampaignFormStoreBase.description',
    context: context,
  );

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  late final _$categoryAtom = Atom(
    name: 'CampaignFormStoreBase.category',
    context: context,
  );

  @override
  CampaignCategory get category {
    _$categoryAtom.reportRead();
    return super.category;
  }

  @override
  set category(CampaignCategory value) {
    _$categoryAtom.reportWrite(value, super.category, () {
      super.category = value;
    });
  }

  late final _$goalAtom = Atom(
    name: 'CampaignFormStoreBase.goal',
    context: context,
  );

  @override
  String get goal {
    _$goalAtom.reportRead();
    return super.goal;
  }

  @override
  set goal(String value) {
    _$goalAtom.reportWrite(value, super.goal, () {
      super.goal = value;
    });
  }

  late final _$deadlineAtom = Atom(
    name: 'CampaignFormStoreBase.deadline',
    context: context,
  );

  @override
  String get deadline {
    _$deadlineAtom.reportRead();
    return super.deadline;
  }

  @override
  set deadline(String value) {
    _$deadlineAtom.reportWrite(value, super.deadline, () {
      super.deadline = value;
    });
  }

  late final _$isSavingAtom = Atom(
    name: 'CampaignFormStoreBase.isSaving',
    context: context,
  );

  @override
  bool get isSaving {
    _$isSavingAtom.reportRead();
    return super.isSaving;
  }

  @override
  set isSaving(bool value) {
    _$isSavingAtom.reportWrite(value, super.isSaving, () {
      super.isSaving = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'CampaignFormStoreBase.errorMessage',
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

  late final _$submitAsyncAction = AsyncAction(
    'CampaignFormStoreBase.submit',
    context: context,
  );

  @override
  Future<Campaign?> submit(String token) {
    return _$submitAsyncAction.run(() => super.submit(token));
  }

  late final _$CampaignFormStoreBaseActionController = ActionController(
    name: 'CampaignFormStoreBase',
    context: context,
  );

  @override
  void populate(Campaign campaign) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.populate',
    );
    try {
      return super.populate(campaign);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTitle(String value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setTitle',
    );
    try {
      return super.setTitle(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDonationInfo(String value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setDonationInfo',
    );
    try {
      return super.setDonationInfo(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSubtitle(String value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setSubtitle',
    );
    try {
      return super.setSubtitle(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDescription(String value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setDescription',
    );
    try {
      return super.setDescription(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCategory(CampaignCategory value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setCategory',
    );
    try {
      return super.setCategory(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGoal(String value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setGoal',
    );
    try {
      return super.setGoal(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDeadline(String value) {
    final _$actionInfo = _$CampaignFormStoreBaseActionController.startAction(
      name: 'CampaignFormStoreBase.setDeadline',
    );
    try {
      return super.setDeadline(value);
    } finally {
      _$CampaignFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
campaignId: ${campaignId},
title: ${title},
donationInfo: ${donationInfo},
subtitle: ${subtitle},
description: ${description},
category: ${category},
goal: ${goal},
deadline: ${deadline},
isSaving: ${isSaving},
errorMessage: ${errorMessage},
deadlineDate: ${deadlineDate},
deadlineValid: ${deadlineValid},
canSubmit: ${canSubmit}
    ''';
  }
}
