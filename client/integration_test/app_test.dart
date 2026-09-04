// End-to-end test: runs the real app widget tree against a real, running
// AjudaBem API (see ApiConfig.baseUrl - defaults to http://localhost:8080,
// override with --dart-define=API_BASE_URL=... if needed).
//
// Requires the API to be up before running this test, e.g.:
//   cd ../api && docker compose up -d db && ./mvnw spring-boot:run
//
// Run with: flutter test integration_test/app_test.dart -d windows
//
// Kept as a single testWidgets scenario on purpose: flutter_modular's
// bindings are global state that doesn't cleanly reset between separate
// testWidgets blocks that each pump a fresh ModularApp, so every step below
// runs against the one app instance pumped at the top.
import 'package:ajuda_bem/app_module.dart';
import 'package:ajuda_bem/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login rejects bad credentials, then register + login succeeds', (
    tester,
  ) async {
    final uniqueEmail =
        'e2e.${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'senha123';
    const name = 'Usuária E2E';

    await tester.pumpWidget(
      ModularApp(module: AppModule(), child: const AppWidget()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seja bem-vindo ao AjudaBem!'), findsOneWidget);

    // 1. Wrong credentials are rejected.
    await _enterText(tester, 'login_email_field', 'nao.existe@example.com');
    await _enterText(tester, 'login_password_field', 'senha-errada');
    await tester.tap(find.byKey(const Key('login_submit_button')));

    await _waitUntilFound(
      tester,
      find.text('Não foi possível entrar. Confira seu e-mail e sua senha.'),
    );
    expect(find.text('Seja bem-vindo ao AjudaBem!'), findsOneWidget);

    // Dismiss the error SnackBar explicitly instead of waiting out its
    // auto-dismiss timer - while showing, it can absorb pointer events over
    // the rest of the screen.
    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // 2. Register a new account.
    await _tapUntilFound(
      tester,
      tapFinder: find.text('Criar conta'),
      waitFor: find.text('Crie sua conta no AjudaBem.'),
    );
    // let the page transition animation fully finish before any
    // coordinate-based taps (e.g. the terms checkbox below), or they can
    // land on a still-moving widget and miss.
    await tester.pumpAndSettle();

    await _enterText(tester, 'register_name_field', name);
    await _enterText(tester, 'register_email_field', uniqueEmail);
    await _enterText(tester, 'register_phone_field', '49999990000');
    await _enterText(tester, 'register_password_field', password);
    await _enterText(tester, 'register_confirm_password_field', password);

    // Tap the checkbox icon itself, not the surrounding InkWell/text: the
    // terms paragraph has embedded TapGestureRecognizers ("Termos de Uso",
    // "Política de Privacidade") that can win the gesture arena over the
    // outer InkWell if the tap lands on the wrapped text instead of the icon.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('register_accept_terms')),
        matching: find.byType(Icon),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('register_submit_button')));

    await _waitUntilFound(
      tester,
      find.text('Cadastro realizado com sucesso!'),
    );

    // Registering navigates back to the login page once the SnackBar is shown.
    await _waitUntilFound(
      tester,
      find.text('Seja bem-vindo ao AjudaBem!'),
      timeout: const Duration(seconds: 10),
    );

    // 3. Log in with the account just created.
    await _enterText(tester, 'login_email_field', uniqueEmail);
    await _enterText(tester, 'login_password_field', password);
    await tester.tap(find.byKey(const Key('login_submit_button')));

    await _waitUntilFound(tester, find.text(name));
  });
}

Future<void> _enterText(WidgetTester tester, String fieldKey, String value) async {
  final field = find.descendant(
    of: find.byKey(Key(fieldKey)),
    matching: find.byType(TextField),
  );
  await tester.enterText(field, value);
  await tester.pump();
}

/// Taps [tapFinder], then waits for [waitFor] to appear; if it doesn't show
/// up within [step] * a few tries (e.g. because the tap landed on a
/// transient overlay instead of the intended widget), retries the tap.
Future<void> _tapUntilFound(
  WidgetTester tester, {
  required Finder tapFinder,
  required Finder waitFor,
  int maxAttempts = 5,
  Duration step = const Duration(milliseconds: 400),
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    await tester.ensureVisible(tapFinder);
    await tester.pumpAndSettle();
    await tester.tap(tapFinder, warnIfMissed: false);
    await tester.pump(step);

    if (waitFor.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(waitFor, findsOneWidget);
}

/// Polls with short real-time pumps until [finder] matches something.
///
/// A plain `pumpAndSettle()` isn't safe here: the app makes a real HTTP call
/// on submit, and once the response lands a SnackBar appears and later
/// auto-dismisses itself on a timer, which `pumpAndSettle()` would also wait
/// out - risking checking for text after it has already disappeared again.
Future<void> _waitUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
  Duration step = const Duration(milliseconds: 200),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  // ignore: avoid_print
  print(
    'DEBUG texts on screen: '
    '${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList()}',
  );
  expect(finder, findsOneWidget);
}
