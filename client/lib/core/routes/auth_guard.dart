import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';

import '../../modules/auth/presentation/stores/login_store.dart';
import 'app_routes.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: AppRoutes.auth);

  static bool get isSignedIn =>
      Modular.tryGet<LoginStore>()?.isAuthenticated ?? false;

  @override
  FutureOr<bool> canActivate(String path, ParallelRoute route) => isSignedIn;
}
