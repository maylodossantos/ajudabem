import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/presentation/widgets/care_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  testWidgets('shows every need with its icon when they fit', (tester) async {
    await pump(tester, const NeedChips(needs: ['Alimentação', 'Moradia']));

    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });

  testWidgets('groups the extra needs into a "+N" tag', (tester) async {
    await pump(
      tester,
      const NeedChips(
        needs: ['Alimentação', 'Moradia', 'Saúde', 'Roupas', 'Higiene'],
        maxVisible: 4,
      ),
    );

    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('Saúde'), findsOneWidget);
    expect(find.text('Roupas'), findsNothing);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('the urgency badge names the level', (tester) async {
    await pump(tester, const UrgencyBadge(urgency: Urgency.high));
    expect(find.text('Urgência alta'), findsOneWidget);

    await pump(tester, const UrgencyBadge(urgency: Urgency.pending));
    expect(find.text('Em triagem'), findsOneWidget);
  });
}
