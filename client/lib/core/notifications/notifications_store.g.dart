// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotificationsStore on NotificationsStoreBase, Store {
  Computed<List<(String, List<AppNotification>)>>? _$groupsComputed;

  @override
  List<(String, List<AppNotification>)> get groups =>
      (_$groupsComputed ??= Computed<List<(String, List<AppNotification>)>>(
        () => super.groups,
        name: 'NotificationsStoreBase.groups',
      )).value;

  late final _$notificationsAtom = Atom(
    name: 'NotificationsStoreBase.notifications',
    context: context,
  );

  @override
  List<AppNotification> get notifications {
    _$notificationsAtom.reportRead();
    return super.notifications;
  }

  @override
  set notifications(List<AppNotification> value) {
    _$notificationsAtom.reportWrite(value, super.notifications, () {
      super.notifications = value;
    });
  }

  late final _$unreadAtom = Atom(
    name: 'NotificationsStoreBase.unread',
    context: context,
  );

  @override
  int get unread {
    _$unreadAtom.reportRead();
    return super.unread;
  }

  @override
  set unread(int value) {
    _$unreadAtom.reportWrite(value, super.unread, () {
      super.unread = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'NotificationsStoreBase.isLoading',
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
    name: 'NotificationsStoreBase.errorMessage',
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

  late final _$refreshUnreadAsyncAction = AsyncAction(
    'NotificationsStoreBase.refreshUnread',
    context: context,
  );

  @override
  Future<void> refreshUnread(String token, {bool force = false}) {
    return _$refreshUnreadAsyncAction.run(
      () => super.refreshUnread(token, force: force),
    );
  }

  late final _$loadAsyncAction = AsyncAction(
    'NotificationsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load(String token) {
    return _$loadAsyncAction.run(() => super.load(token));
  }

  late final _$markReadAsyncAction = AsyncAction(
    'NotificationsStoreBase.markRead',
    context: context,
  );

  @override
  Future<void> markRead(AppNotification notification, String token) {
    return _$markReadAsyncAction.run(() => super.markRead(notification, token));
  }

  late final _$markAllReadAsyncAction = AsyncAction(
    'NotificationsStoreBase.markAllRead',
    context: context,
  );

  @override
  Future<void> markAllRead(String token) {
    return _$markAllReadAsyncAction.run(() => super.markAllRead(token));
  }

  late final _$NotificationsStoreBaseActionController = ActionController(
    name: 'NotificationsStoreBase',
    context: context,
  );

  @override
  void clear() {
    final _$actionInfo = _$NotificationsStoreBaseActionController.startAction(
      name: 'NotificationsStoreBase.clear',
    );
    try {
      return super.clear();
    } finally {
      _$NotificationsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
notifications: ${notifications},
unread: ${unread},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
groups: ${groups}
    ''';
  }
}
