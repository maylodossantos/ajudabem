import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../modules/profile/presentation/stores/profile_store.dart';
import '../routes/app_routes.dart';
import '../routes/auth_guard.dart';
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
      return _navigation(context, canPublishNews: false, isOng: false);
    }

    return Observer(
      builder: (_) => _navigation(
        context,
        canPublishNews: store.profile?.canPublishNews ?? false,
        isOng: store.profile?.isOng ?? false,
      ),
    );
  }

  Widget _navigation(
    BuildContext context, {
    required bool canPublishNews,
    required bool isOng,
  }) {
    final signedIn = isSignedIn ?? AuthGuard.isSignedIn;

    return AppBottomNavigation(
      currentItem: currentItem,
      onNews: () => _go(AppRoutes.news),
      onHelp: () => _go(AppRoutes.helpPoints),
      onProfile: () => _go(signedIn ? AppRoutes.profile : AppRoutes.auth),
      onRegister: signedIn
          ? () => _go(AppRoutes.registrationMenu)
          : () => showAppSnackBar(
              context,
              'Faça login para acessar o menu de cadastro.',
            ),
      showCreateNews: canPublishNews,
      onCreateNews: () => Modular.to.pushNamed(AppRoutes.newsForm),
      showOng: isOng,
      onOng: () => _go(AppRoutes.ong),
    );
  }

  void _go(String route) {
    if (Modular.to.path != route) {
      Modular.to.navigate(route);
    }
  }
}
