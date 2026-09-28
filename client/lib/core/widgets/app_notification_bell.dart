import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../modules/auth/presentation/stores/login_store.dart';
import '../notifications/notifications_store.dart';
import '../routes/app_routes.dart';

class AppNotificationBell extends StatefulWidget {
  const AppNotificationBell({super.key});

  @override
  State<AppNotificationBell> createState() => _AppNotificationBellState();
}

class _AppNotificationBellState extends State<AppNotificationBell> {
  final NotificationsStore? _store = Modular.tryGet<NotificationsStore>();
  final String? _token = Modular.tryGet<LoginStore>()?.authToken;

  @override
  void initState() {
    super.initState();
    final token = _token;
    if (token != null) _store?.refreshUnread(token);
  }

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      'assets/icons/notify_icon.svg',
      width: 32,
      height: 32,
    );
    final store = _store;
    if (store == null || _token == null) return icon;

    return IconButton(
      key: const Key('notification_bell'),
      tooltip: 'Notificações',
      onPressed: () => Modular.to.pushNamed(AppRoutes.notifications),
      icon: Observer(
        builder: (_) {
          final unread = store.unread;
          if (unread == 0) return icon;
          return Badge(
            label: Text(
              unread > 9 ? '9+' : '$unread',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: const Color(0xFFE5484D),
            child: icon,
          );
        },
      ),
    );
  }
}
