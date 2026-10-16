import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../modules/profile/presentation/stores/profile_store.dart';
import '../routes/app_routes.dart';
import '../routes/auth_guard.dart';
import '../routes/tab_transition.dart';
import 'app_bottom_navigation.dart';
import 'app_feedback.dart';

class AppMainNavigation extends StatelessWidget {
  const AppMainNavigation({
    required this.currentItem,
    super.key,
    this.profileStore,
    this.isSignedIn,
  });

  final AppNavigationItem currentItem;

  final ProfileStore? profileStore;

  final bool? isSignedIn;

  @override
  Widget build(BuildContext context) {
    final store = profileStore ?? Modular.tryGet<ProfileStore>();
    if (store == null) {
      return _navigation(context, isOng: false);
    }

    return Observer(
      builder: (_) =>
          _navigation(context, isOng: store.profile?.isOng ?? false),
    );
  }

  Widget _navigation(BuildContext context, {required bool isOng}) {
    final signedIn = isSignedIn ?? AuthGuard.isSignedIn;

    return Hero(
      tag: 'app-main-navigation',
      child: Material(
        type: MaterialType.transparency,
        child: AppBottomNavigation(
          currentItem: currentItem,
          onNews: () => _go(AppRoutes.news, AppNavigationItem.news),
          onHelp: () => _go(AppRoutes.helpPoints, AppNavigationItem.help),
          onProfile: () => _go(
            signedIn ? AppRoutes.profile : AppRoutes.auth,
            AppNavigationItem.profile,
          ),
          onRegister: signedIn
              ? () =>
                    _go(AppRoutes.registrationMenu, AppNavigationItem.register)
              : () => showAppSnackBar(
                  context,
                  'Faça login para acessar o menu de cadastro.',
                ),
          showOng: isOng,
          onOng: () => _go(AppRoutes.ong, AppNavigationItem.ong),
        ),
      ),
    );
  }

  void _go(String route, AppNavigationItem target) {
    if (Modular.to.path != route) {
      TabTransition.moving(currentItem.index, target.index);
      Modular.to.navigate(route);
    }
  }
}
