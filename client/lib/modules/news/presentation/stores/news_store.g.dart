// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NewsStore on NewsStoreBase, Store {
  late final _$articlesAtom = Atom(
    name: 'NewsStoreBase.articles',
    context: context,
  );

  @override
  List<NewsArticle> get articles {
    _$articlesAtom.reportRead();
    return super.articles;
  }

  @override
  set articles(List<NewsArticle> value) {
    _$articlesAtom.reportWrite(value, super.articles, () {
      super.articles = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'NewsStoreBase.isLoading',
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
    name: 'NewsStoreBase.errorMessage',
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
    name: 'NewsStoreBase.deletingIds',
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
    'NewsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String? token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$deleteArticleAsyncAction = AsyncAction(
    'NewsStoreBase.deleteArticle',
    context: context,
  );

  @override
  Future<bool> deleteArticle(int id, String token) {
    return _$deleteArticleAsyncAction.run(() => super.deleteArticle(id, token));
  }

  @override
  String toString() {
    return '''
articles: ${articles},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
deletingIds: ${deletingIds}
    ''';
  }
}
