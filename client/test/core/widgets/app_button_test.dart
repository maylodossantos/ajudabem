import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary button handles tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Entrar',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Entrar'));
    expect(tapped, isTrue);
  });

  testWidgets('primary button shows a spinner and blocks taps while loading', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Entrar',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Entrar'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    expect(tapped, isFalse);
  });

  testWidgets('outlined button renders label and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppOutlinedButton(
            label: 'Faça login com o Google',
            icon: const Icon(Icons.login),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Faça login com o Google'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });

  testWidgets('text button renders icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextButton(
            label: 'Criar conta',
            icon: Icons.person_add_alt_outlined,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person_add_alt_outlined), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
