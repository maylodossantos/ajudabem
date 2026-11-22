import 'package:ajuda_bem/modules/auth/presentation/widgets/dev_quick_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('offers one shortcut per role and returns the tapped account', (
    tester,
  ) async {
    DevAccount? selected;
    await pump(tester, DevQuickLogin(onSelected: (a) => selected = a));

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('ONG'), findsOneWidget);
    expect(find.text('ONG 2'), findsOneWidget);
    expect(find.text('Usuário'), findsOneWidget);

    await tester.tap(find.byKey(const Key('dev_login_ong@ajudabem.local')));
    expect(selected?.email, 'ong@ajudabem.local');

    await tester.tap(find.byKey(const Key('dev_login_ong2@ajudabem.local')));
    expect(selected?.email, 'ong2@ajudabem.local');
  });

  testWidgets('ignores taps while disabled', (tester) async {
    DevAccount? selected;
    await pump(
      tester,
      DevQuickLogin(enabled: false, onSelected: (a) => selected = a),
    );

    await tester.tap(find.byKey(const Key('dev_login_admin@ajudabem.local')));
    expect(selected, isNull);
  });
}
