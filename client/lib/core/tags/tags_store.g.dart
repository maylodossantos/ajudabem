// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TagsStore on TagsStoreBase, Store {
  late final _$tagsAtom = Atom(name: 'TagsStoreBase.tags', context: context);

  @override
  List<NeedTag> get tags {
    _$tagsAtom.reportRead();
    return super.tags;
  }

  @override
  set tags(List<NeedTag> value) {
    _$tagsAtom.reportWrite(value, super.tags, () {
      super.tags = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'TagsStoreBase.isLoading',
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
    name: 'TagsStoreBase.errorMessage',
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

  late final _$isSavingAtom = Atom(
    name: 'TagsStoreBase.isSaving',
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

  late final _$ensureLoadedAsyncAction = AsyncAction(
    'TagsStoreBase.ensureLoaded',
    context: context,
  );

  @override
  Future<void> ensureLoaded(String token) {
    return _$ensureLoadedAsyncAction.run(() => super.ensureLoaded(token));
  }

  late final _$loadAsyncAction = AsyncAction(
    'TagsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$_changeAsyncAction = AsyncAction(
    'TagsStoreBase._change',
    context: context,
  );

  @override
  Future<bool> _change(Future<void> Function() change) {
    return _$_changeAsyncAction.run(() => super._change(change));
  }

  late final _$TagsStoreBaseActionController = ActionController(
    name: 'TagsStoreBase',
    context: context,
  );

  @override
  Future<bool> save(String name, String token, {int? id}) {
    final _$actionInfo = _$TagsStoreBaseActionController.startAction(
      name: 'TagsStoreBase.save',
    );
    try {
      return super.save(name, token, id: id);
    } finally {
      _$TagsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> delete(int id, String token) {
    final _$actionInfo = _$TagsStoreBaseActionController.startAction(
      name: 'TagsStoreBase.delete',
    );
    try {
      return super.delete(id, token);
    } finally {
      _$TagsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
tags: ${tags},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isSaving: ${isSaving}
    ''';
  }
}
