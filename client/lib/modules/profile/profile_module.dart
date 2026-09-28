import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import 'presentation/pages/needs_admin_page.dart';
import 'presentation/pages/about_config_page.dart';
import 'presentation/pages/delete_account_confirm_page.dart';
import 'presentation/pages/profile_edit_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/stores/profile_edit_store.dart';

class ProfileModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.add(ProfileEditStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.profile,
      guards: [AuthGuard()],
      child: (_) => const ProfilePage(),
    );
    r.child(
      AppRoutes.profileEdit,
      guards: [AuthGuard()],
      child: (_) => const ProfileEditPage(),
    );
    r.child(
      AppRoutes.needsAdmin,
      guards: [AuthGuard()],
      child: (_) => const NeedsAdminPage(),
    );
    r.child(
      AppRoutes.aboutConfig,
      guards: [AuthGuard()],
      child: (_) => const AboutConfigPage(),
    );
    r.child(
      AppRoutes.deleteAccountConfirm,
      guards: [AuthGuard()],
      child: (_) => const DeleteAccountConfirmPage(),
    );
  }
}
