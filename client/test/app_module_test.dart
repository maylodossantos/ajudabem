import 'package:ajuda_bem/app_module.dart';
import 'package:ajuda_bem/app_widget.dart';
import 'package:ajuda_bem/core/routes/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression test for the module split (Auth/News/Profile/Registration modules
// mounted from AppModule): flutter_modular's injector only resolves a bind's
// constructor parameters against binds in the SAME module or one it imports,
// never "upward" into whichever module mounted it - not even lazily. A store or
// datasource that needs something from another module (http.Client, LoginStore)
// has to come through that module's `imports`, or this throws at navigation time.
// Mocked unit tests can't catch this since they never boot the real DI graph.
void main() {
  testWidgets('every route resolves its dependencies without a DI error', (
    tester,
  ) async {
    await tester.pumpWidget(
      ModularApp(module: AppModule(), child: const AppWidget()),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    for (final path in [
      AppRoutes.news,
      AppRoutes.profile,
      AppRoutes.profileEdit,
      AppRoutes.aboutConfig,
      AppRoutes.deleteAccountConfirm,
      AppRoutes.registrationMenu,
      AppRoutes.assistedPeople,
      AppRoutes.register,
      AppRoutes.recoverAccess,
      AppRoutes.verifyCode,
      AppRoutes.resetPassword,
      AppRoutes.termsOfUse,
    ]) {
      Modular.to.navigate(path);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull, reason: 'navigating to $path');
    }
  });
}
