import 'dart:convert';

import 'package:ajuda_bem/core/notifications/app_notification.dart';
import 'package:ajuda_bem/core/notifications/notifications_repository.dart';
import 'package:ajuda_bem/core/notifications/notifications_store.dart';
import 'package:ajuda_bem/core/routes/app_routes.dart';
import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:ajuda_bem/modules/notifications/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {'content-type': 'application/json; charset=utf-8'};
  final now = DateTime.now();

  Map<String, dynamic> notification(
    int id,
    String type,
    DateTime createdAt, {
    bool read = false,
  }) => {
    'id': id,
    'type': type,
    'title': 'Título $id',
    'message': 'Mensagem $id',
    'targetId': 10 + id,
    'createdAt': createdAt.toIso8601String(),
    'readAt': read ? createdAt.toIso8601String() : null,
  };

  NotificationsStore storeWith(
    List<Map<String, dynamic>> items,
    List<String> posted,
  ) {
    return NotificationsStore(
      NotificationsRepository(
        MockClient((request) async {
          if (request.method == 'POST') {
            posted.add(request.url.path);
            return http.Response('', 204);
          }
          if (request.url.path.endsWith('unread-count')) {
            return http.Response(jsonEncode({'unread': 7}), 200, headers: json);
          }
          return http.Response(jsonEncode(items), 200, headers: json);
        }),
      ),
    );
  }

  test('groups by day and keeps the unread count in sync', () async {
    final posted = <String>[];
    final store = storeWith([
      notification(1, 'CAMPAIGN_CREATED', now),
      notification(2, 'CASE_ASSUMED', now.subtract(const Duration(days: 1))),
      notification(
        3,
        'VOLUNTEER_APPLIED',
        DateTime(2025, 11, 23, 12),
        read: true,
      ),
    ], posted);

    await store.load('jwt');

    expect(store.groups.map((group) => group.$1), [
      'Hoje',
      'Ontem',
      '23 de novembro',
    ]);
    expect(store.unread, 2);

    await store.markRead(store.notifications.first, 'jwt');
    expect(store.unread, 1);
    expect(posted, ['/notification/1/read']);

    await store.markAllRead('jwt');
    expect(store.unread, 0);
    expect(store.notifications.every((item) => item.isRead), isTrue);
    expect(posted.last, '/notification/read-all');
  });

  test('refreshing the badge is throttled', () async {
    final store = storeWith(const [], []);
    await store.refreshUnread('jwt');
    expect(store.unread, 7);

    store.unread = 0;
    await store.refreshUnread('jwt');
    expect(store.unread, 0);

    await store.refreshUnread('jwt', force: true);
    expect(store.unread, 7);
  });

  test('each notification opens the matching screen', () {
    AppNotification of(NotificationType type) => AppNotification(
      id: 1,
      type: type,
      title: '',
      message: '',
      targetId: 5,
      createdAt: now,
    );

    expect(
      NotificationsPage.destinationOf(of(NotificationType.caseNominated)),
      (AppRoutes.careCase, 5),
    );
    final campaign = NotificationsPage.destinationOf(
      of(NotificationType.campaignCreated),
    );
    expect(campaign?.$1, AppRoutes.campaignDetail);
    expect((campaign?.$2 as InitiativeArgs).id, 5);
    expect(
      NotificationsPage.destinationOf(of(NotificationType.volunteerApplied)),
      (AppRoutes.actionVolunteers, 5),
    );
    expect(
      NotificationsPage.destinationOf(of(NotificationType.caseFinished))?.$1,
      AppRoutes.assistedPeople,
    );
    expect(
      NotificationsPage.destinationOf(of(NotificationType.unknown)),
      isNull,
    );
  });

  testWidgets('without notifications the page shows the empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NotificationsPage(store: storeWith(const [], []), token: 'jwt'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma notificação ainda'), findsOneWidget);
    expect(find.byKey(const Key('notifications_read_all')), findsNothing);
  });
}
