import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import 'notifications_page.dart';

class NotificationsModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.notifications,
      guards: [AuthGuard()],
      child: (_) => const NotificationsPage(),
    );
  }
}
