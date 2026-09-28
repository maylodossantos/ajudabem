// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_stores.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CampaignDetailStore on CampaignDetailStoreBase, Store {
  late final _$campaignAtom = Atom(
    name: 'CampaignDetailStoreBase.campaign',
    context: context,
  );

  @override
  Campaign? get campaign {
    _$campaignAtom.reportRead();
    return super.campaign;
  }

  @override
  set campaign(Campaign? value) {
    _$campaignAtom.reportWrite(value, super.campaign, () {
      super.campaign = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'CampaignDetailStoreBase.isLoading',
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

  late final _$isFinishingAtom = Atom(
    name: 'CampaignDetailStoreBase.isFinishing',
    context: context,
  );

  @override
  bool get isFinishing {
    _$isFinishingAtom.reportRead();
    return super.isFinishing;
  }

  @override
  set isFinishing(bool value) {
    _$isFinishingAtom.reportWrite(value, super.isFinishing, () {
      super.isFinishing = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'CampaignDetailStoreBase.errorMessage',
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
    'CampaignDetailStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(int id) {
    return _$loadAsyncAction.run(() => super.load(id));
  }

  late final _$finishAsyncAction = AsyncAction(
    'CampaignDetailStoreBase.finish',
    context: context,
  );

  @override
  Future<bool> finish(String token) {
    return _$finishAsyncAction.run(() => super.finish(token));
  }

  late final _$CampaignDetailStoreBaseActionController = ActionController(
    name: 'CampaignDetailStoreBase',
    context: context,
  );

  @override
  void show(Campaign value) {
    final _$actionInfo = _$CampaignDetailStoreBaseActionController.startAction(
      name: 'CampaignDetailStoreBase.show',
    );
    try {
      return super.show(value);
    } finally {
      _$CampaignDetailStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
campaign: ${campaign},
isLoading: ${isLoading},
isFinishing: ${isFinishing},
errorMessage: ${errorMessage}
    ''';
  }
}

mixin _$CampaignsFeedStore on CampaignsFeedStoreBase, Store {
  late final _$campaignsAtom = Atom(
    name: 'CampaignsFeedStoreBase.campaigns',
    context: context,
  );

  @override
  List<Campaign> get campaigns {
    _$campaignsAtom.reportRead();
    return super.campaigns;
  }

  @override
  set campaigns(List<Campaign> value) {
    _$campaignsAtom.reportWrite(value, super.campaigns, () {
      super.campaigns = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'CampaignsFeedStoreBase.isLoading',
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
    name: 'CampaignsFeedStoreBase.errorMessage',
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
    'CampaignsFeedStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  @override
  String toString() {
    return '''
campaigns: ${campaigns},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
