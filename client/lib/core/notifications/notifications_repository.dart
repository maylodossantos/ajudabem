import 'package:http/http.dart' as http;

import '../network/api_requester.dart';
import 'app_notification.dart';

class NotificationsRepository {
  NotificationsRepository(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  Future<List<AppNotification>> mine(String token) {
    return _api.request(
      HttpMethod.get,
      '/notification',
      token: token,
      errorMessage: 'Não foi possível carregar as notificações.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) => ApiRequester.decodeList(
        response,
      ).map(AppNotification.fromJson).toList(),
    );
  }

  Future<int> unreadCount(String token) {
    return _api.request(
      HttpMethod.get,
      '/notification/unread-count',
      token: token,
      errorMessage: 'Não foi possível carregar as notificações.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          (ApiRequester.decodeObject(response)['unread'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> markRead(int id, String token) {
    return _api.request(
      HttpMethod.post,
      '/notification/$id/read',
      token: token,
      errorMessage: 'Não foi possível atualizar a notificação.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (_) {},
    );
  }

  Future<void> markAllRead(String token) {
    return _api.request(
      HttpMethod.post,
      '/notification/read-all',
      token: token,
      errorMessage: 'Não foi possível atualizar as notificações.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (_) {},
    );
  }
}
