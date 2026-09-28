import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/notifications/app_notification.dart';
import '../../core/notifications/notifications_store.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_bottom_navigation.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_page_scaffold.dart';
import '../../core/widgets/app_status_view.dart';
import '../auth/presentation/stores/login_store.dart';
import '../initiatives/domain/entities/campaign.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.store, this.token});

  final NotificationsStore? store;
  final String? token;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();

  static (String, Object?)? destinationOf(AppNotification notification) {
    final id = notification.targetId;
    return switch (notification.type) {
      NotificationType.caseNominated when id != null => (
        AppRoutes.careCase,
        id,
      ),
      NotificationType.caseAssumed ||
      NotificationType.caseFinished => (AppRoutes.assistedPeople, null),
      NotificationType.campaignCreated when id != null => (
        AppRoutes.campaignDetail,
        InitiativeArgs(id),
      ),
      NotificationType.actionCreated || NotificationType.applicationAccepted
          when id != null =>
        (AppRoutes.actionDetail, InitiativeArgs(id)),
      NotificationType.volunteerApplied when id != null => (
        AppRoutes.actionVolunteers,
        id,
      ),
      NotificationType.organizationApproved => (AppRoutes.ong, null),
      NotificationType.organizationRejected => (AppRoutes.ongValidation, null),
      _ => null,
    };
  }
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsStore _store;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<NotificationsStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(token);
  }

  Future<void> _open(AppNotification notification) async {
    final token = _token;
    if (token != null) _store.markRead(notification, token);
    final destination = NotificationsPage.destinationOf(notification);
    if (destination != null) {
      await Modular.to.pushNamed(destination.$1, arguments: destination.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AppPageScaffold(
      currentItem: AppNavigationItem.profile,
      body: Observer(
        builder: (_) {
          final groups = _store.groups;
          final error = _store.errorMessage;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Notificações',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (_store.unread > 0)
                      TextButton(
                        key: const Key('notifications_read_all'),
                        onPressed: () {
                          final token = _token;
                          if (token != null) _store.markAllRead(token);
                        },
                        child: const Text('Marcar todas como lidas'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _store.isLoading && groups.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : error != null && groups.isEmpty
                    ? AppErrorView(message: error, onRetry: _load)
                    : groups.isEmpty
                    ? const AppStatusView(
                        illustration: Image(
                          image: AssetImage(
                            'assets/illustrations/empty_notifications.png',
                          ),
                        ),
                        title: 'Nenhuma notificação ainda',
                        message:
                            'Suas notificações aparecerão aqui quando houver '
                            'novidades.',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          children: [
                            for (final (label, items) in groups) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 8,
                                ),
                                child: Text(
                                  label,
                                  style: GoogleFonts.manrope(
                                    color: primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              for (final notification in items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _NotificationTile(
                                    notification: notification,
                                    onTap: () => _open(notification),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  static IconData iconOf(NotificationType type) => switch (type) {
    NotificationType.caseNominated => Icons.person_pin_circle_outlined,
    NotificationType.caseAssumed => Icons.volunteer_activism_outlined,
    NotificationType.caseFinished => Icons.task_alt,
    NotificationType.campaignCreated => Icons.campaign_outlined,
    NotificationType.actionCreated => Icons.groups_outlined,
    NotificationType.volunteerApplied => Icons.person_add_alt_1_outlined,
    NotificationType.applicationAccepted => Icons.check_circle_outline,
    NotificationType.organizationApproved => Icons.verified_outlined,
    NotificationType.organizationRejected => Icons.error_outline,
    NotificationType.unknown => Icons.notifications_none,
  };

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final unread = !notification.isRead;

    return Material(
      color: unread ? const Color(0xFFEFFAF7) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('notification_${notification.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFCFF2EC),
                child: Icon(iconOf(notification.type), color: primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: GoogleFonts.manrope(fontSize: 13.5, height: 1.3),
                    ),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.circle, size: 10, color: primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
