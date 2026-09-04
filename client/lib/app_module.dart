import 'package:flutter_modular/flutter_modular.dart';

import 'core/routes/app_routes.dart';
import 'modules/auth/auth_module.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module(AppRoutes.auth, module: AuthModule());
  }
}
