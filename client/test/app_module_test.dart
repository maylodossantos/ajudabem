import 'dart:convert';

import 'package:ajuda_bem/app_module.dart';
import 'package:ajuda_bem/app_widget.dart';
import 'package:ajuda_bem/core/routes/app_routes.dart';
import 'package:ajuda_bem/modules/auth/presentation/stores/login_store.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {'content-type': 'application/json; charset=utf-8'};

  final api = MockClient((request) async {
    if (request.url.path.endsWith('/auth/login')) {
      return http.Response(
        jsonEncode({'name': 'Maria', 'token': 'jwt'}),
        200,
        headers: json,
      );
    }
    final path = request.url.path;
    final isList =
        path.endsWith('/news') ||
        path.endsWith('/campaign') ||
        path.endsWith('/mine') ||
        path.endsWith('/cases') ||
        path.endsWith('/nominated') ||
        path.endsWith('/map') ||
        path.endsWith('/notification') ||
        path.endsWith('/help-point') ||
        path.endsWith('/tag') ||
        path.endsWith('/volunteer-action') ||
        path.endsWith('/volunteers') ||
        path.endsWith('/assisted-person');
    return http.Response(isList ? '[]' : '{}', 200, headers: json);
  });

  Future<void> visit(WidgetTester tester, String path, [Object? args]) async {
    Modular.to.navigate(path, arguments: args);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'navigating to $path');
  }

  testWidgets(
    'every route resolves its dependencies without a DI error',
    (tester) => http.runWithClient(() => _visitAll(tester, visit), () => api),
  );
}

Future<void> _visitAll(
  WidgetTester tester,
  Future<void> Function(WidgetTester, String, [Object?]) visit,
) async {
  await tester.pumpWidget(
    ModularApp(module: AppModule(), child: const AppWidget()),
  );
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);

  final login = Modular.get<LoginStore>()
    ..setEmail('maria@example.com')
    ..setPassword('secret');
  expect(await login.submit(), isTrue);

  for (final path in [
    AppRoutes.news,
    AppRoutes.helpPoints,
    AppRoutes.profile,
    AppRoutes.profileEdit,
    AppRoutes.aboutConfig,
    AppRoutes.deleteAccountConfirm,
    AppRoutes.needsAdmin,
    AppRoutes.registrationMenu,
    AppRoutes.assistedPeople,
    AppRoutes.register,
    AppRoutes.recoverAccess,
    AppRoutes.verifyCode,
    AppRoutes.resetPassword,
    AppRoutes.termsOfUse,
    AppRoutes.ong,
    AppRoutes.ongValidation,
    AppRoutes.nominatedPeople,
    AppRoutes.peopleInCare,
    AppRoutes.careMap,
    AppRoutes.initiatives,
    AppRoutes.initiativeChooser,
    AppRoutes.campaignForm,
    AppRoutes.actionForm,
    AppRoutes.volunteerActions,
    AppRoutes.notifications,
  ]) {
    await visit(tester, path);
  }

  await visit(tester, AppRoutes.campaignDetail, const InitiativeArgs(1));
  await visit(tester, AppRoutes.actionDetail, const InitiativeArgs(1));
  await visit(tester, AppRoutes.actionVolunteers, 1);
  await visit(tester, AppRoutes.careCase, 1);
}
