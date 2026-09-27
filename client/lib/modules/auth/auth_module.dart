import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import 'domain/usecases/register_user_usecase.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/recover_access_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/reset_password_page.dart';
import 'presentation/pages/terms_of_use_page.dart';
import 'presentation/pages/verify_code_page.dart';
import 'presentation/stores/recover_access_store.dart';
import 'presentation/stores/register_store.dart';

class AuthModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addSingleton(RegisterUserUsecase.new);
    i.addSingleton(RecoverAccessStore.new);
    i.addSingleton(RegisterStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(AppRoutes.auth, child: (_) => const LoginPage());
    r.child(AppRoutes.recoverAccess, child: (_) => const RecoverAccessPage());
    r.child(AppRoutes.verifyCode, child: (_) => const VerifyCodePage());
    r.child(AppRoutes.resetPassword, child: (_) => const ResetPasswordPage());
    r.child(AppRoutes.register, child: (_) => const RegisterPage());
    r.child(AppRoutes.termsOfUse, child: (_) => const TermsOfUsePage());
  }
}
