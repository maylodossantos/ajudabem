import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary button renders style and handles tap', (tester) async {
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

    final text = tester.widget<Text>(find.text('Entrar'));
    expect(text.style?.fontFamily, contains('Manrope'));
    expect(text.style?.fontSize, 16);
    expect(text.style?.fontWeight, FontWeight.w700);
    expect(text.style?.color, Colors.white);

    await tester.tap(find.text('Entrar'));
    expect(tapped, isTrue);
  });

  testWidgets('outlined button renders Manrope green text', (tester) async {
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

    final text = tester.widget<Text>(find.text('Faça login com o Google'));
    expect(text.style?.fontFamily, contains('Manrope'));
    expect(text.style?.fontSize, 14);
    expect(text.style?.fontWeight, FontWeight.w700);
    expect(text.style?.color, const Color(0xFF04957C));
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
    final text = tester.widget<Text>(find.text('Criar conta'));
    expect(text.style?.fontFamily, contains('Manrope'));
    expect(text.style?.fontSize, 14);
    expect(text.style?.color, const Color(0xFF04957C));
  });
}
