// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NewsFormStore on NewsFormStoreBase, Store {
  Computed<bool>? _$isEditingComputed;

  @override
  bool get isEditing => (_$isEditingComputed ??= Computed<bool>(
    () => super.isEditing,
    name: 'NewsFormStoreBase.isEditing',
  )).value;
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'NewsFormStoreBase.canSubmit',
  )).value;

  late final _$articleIdAtom = Atom(
    name: 'NewsFormStoreBase.articleId',
    context: context,
  );

  @override
  int? get articleId {
    _$articleIdAtom.reportRead();
    return super.articleId;
  }

  @override
  set articleId(int? value) {
    _$articleIdAtom.reportWrite(value, super.articleId, () {
      super.articleId = value;
    });
  }

  late final _$titleAtom = Atom(
    name: 'NewsFormStoreBase.title',
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

  late final _$subtitleAtom = Atom(
    name: 'NewsFormStoreBase.subtitle',
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

  late final _$contentAtom = Atom(
    name: 'NewsFormStoreBase.content',
    context: context,
  );

  @override
  String get content {
    _$contentAtom.reportRead();
    return super.content;
  }

  @override
  set content(String value) {
    _$contentAtom.reportWrite(value, super.content, () {
      super.content = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'NewsFormStoreBase.isLoading',
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
    name: 'NewsFormStoreBase.errorMessage',
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
    'NewsFormStoreBase.submit',
    context: context,
  );

  @override
  Future<bool> submit(String token) {
    return _$submitAsyncAction.run(() => super.submit(token));
  }

  late final _$NewsFormStoreBaseActionController = ActionController(
    name: 'NewsFormStoreBase',
    context: context,
  );

  @override
  void populate(NewsArticle article) {
    final _$actionInfo = _$NewsFormStoreBaseActionController.startAction(
      name: 'NewsFormStoreBase.populate',
    );
    try {
      return super.populate(article);
    } finally {
      _$NewsFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTitle(String value) {
    final _$actionInfo = _$NewsFormStoreBaseActionController.startAction(
      name: 'NewsFormStoreBase.setTitle',
    );
    try {
      return super.setTitle(value);
    } finally {
      _$NewsFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSubtitle(String value) {
    final _$actionInfo = _$NewsFormStoreBaseActionController.startAction(
      name: 'NewsFormStoreBase.setSubtitle',
    );
    try {
      return super.setSubtitle(value);
    } finally {
      _$NewsFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setContent(String value) {
    final _$actionInfo = _$NewsFormStoreBaseActionController.startAction(
      name: 'NewsFormStoreBase.setContent',
    );
    try {
      return super.setContent(value);
    } finally {
      _$NewsFormStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
articleId: ${articleId},
title: ${title},
subtitle: ${subtitle},
content: ${content},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isEditing: ${isEditing},
canSubmit: ${canSubmit}
    ''';
  }
}
