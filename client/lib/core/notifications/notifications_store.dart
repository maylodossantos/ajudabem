import 'package:mobx/mobx.dart';

import '../errors/app_exception.dart';
import '../formatters/date_input_formatter.dart';
import 'app_notification.dart';
import 'notifications_repository.dart';

part 'notifications_store.g.dart';

class NotificationsStore = NotificationsStoreBase with _$NotificationsStore;

abstract class NotificationsStoreBase with Store {
  NotificationsStoreBase(this._repository);

  final NotificationsRepository _repository;

  static const refreshInterval = Duration(seconds: 30);

  DateTime? _lastRefresh;

  @observable
  List<AppNotification> notifications = [];

  @observable
  int unread = 0;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  List<(String, List<AppNotification>)> get groups {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String labelOf(DateTime moment) {
      final day = DateTime(moment.year, moment.month, moment.day);
      final daysAgo = today.difference(day).inDays;
      if (daysAgo == 0) return 'Hoje';
      if (daysAgo == 1) return 'Ontem';
      return DateInputFormatter.dayAndMonth(moment);
    }

    final result = <(String, List<AppNotification>)>[];
    for (final notification in notifications) {
      final label = labelOf(notification.createdAt);
      if (result.isNotEmpty && result.last.$1 == label) {
        result.last.$2.add(notification);
      } else {
        result.add((label, [notification]));
      }
    }
    return result;
  }

  @action
  Future<void> refreshUnread(String token, {bool force = false}) async {
    final last = _lastRefresh;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < refreshInterval) {
      return;
    }
    _lastRefresh = DateTime.now();
    try {
      unread = await _repository.unreadCount(token);
    } catch (_) {}
  }

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      notifications = await _repository.mine(token);
      unread = notifications.where((item) => !item.isRead).length;
      _lastRefresh = DateTime.now();
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar as notificações.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> markRead(AppNotification notification, String token) async {
    if (notification.isRead) return;
    notifications = [
      for (final item in notifications)
        item.id == notification.id ? item.read() : item,
    ];
    unread = unread > 0 ? unread - 1 : 0;
    try {
      await _repository.markRead(notification.id, token);
    } catch (_) {}
  }

  @action
  Future<void> markAllRead(String token) async {
    if (unread == 0) return;
    notifications = [for (final item in notifications) item.read()];
    unread = 0;
    try {
      await _repository.markAllRead(token);
    } catch (_) {}
  }

  @action
  void clear() {
    notifications = [];
    unread = 0;
    _lastRefresh = null;
  }
}
