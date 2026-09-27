import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../modules/profile/presentation/stores/profile_store.dart';
import '../routes/app_routes.dart';
import 'app_bottom_navigation.dart';

/// Bottom navigation for signed-in screens: wires every tab to its route and
/// shows the admin-only "Publicar" tab from the shared ProfileStore, so the
/// menu is identical on every screen instead of each page re-wiring it.
class AppMainNavigation extends StatelessWidget {
  const AppMainNavigation({
    required this.currentItem,
    super.key,
    this.profileStore,
  });

  final AppNavigationItem currentItem;

  /// Widget tests inject this; the app resolves it from CoreModule.
  final ProfileStore? profileStore;

  @override
  Widget build(BuildContext context) {
    final store = profileStore ?? Modular.tryGet<ProfileStore>();
    if (store == null) {
      return _navigation(canPublishNews: false);
    }

    return Observer(
      builder: (_) =>
          _navigation(canPublishNews: store.profile?.canPublishNews ?? false),
    );
  }

  Widget _navigation({required bool canPublishNews}) {
    return AppBottomNavigation(
      currentItem: currentItem,
      onNews: () => _go(AppRoutes.news),
      onProfile: () => _go(AppRoutes.profile),
      onRegister: () => _go(AppRoutes.registrationMenu),
      showCreateNews: canPublishNews,
      onCreateNews: () => Modular.to.pushNamed(AppRoutes.newsForm),
    );
  }

  void _go(String route) {
    if (Modular.to.path != route) {
      Modular.to.navigate(route);
    }
  }
}
