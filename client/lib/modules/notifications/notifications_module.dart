import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import '../../core/routes/tab_transition.dart';
import 'notifications_page.dart';

class NotificationsModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.notifications,
      guards: [AuthGuard()],
      transition: TransitionType.custom,
      customTransition: TabTransition.rise,
      child: (_) => const NotificationsPage(),
    );
  }
}
