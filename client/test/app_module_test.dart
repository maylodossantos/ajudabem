import 'package:ajuda_bem/app_module.dart';
import 'package:ajuda_bem/app_widget.dart';
import 'package:ajuda_bem/core/routes/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

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
