import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders label, hint and expected typography', (tester) async {
    var value = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextField(
            label: 'E-mail:',
            hintText: 'E-mail',
            prefixIconAsset: 'assets/icons/register/email.svg',
            keyboardType: TextInputType.emailAddress,
            onChanged: (text) => value = text,
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('E-mail:'));
    expect(label.style?.fontFamily, contains('Manrope'));
    expect(label.style?.fontSize, 16);
    expect(label.style?.fontWeight, FontWeight.w700);
    expect(label.style?.color, const Color(0xFF04957C));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.emailAddress);
    expect(textField.style?.fontFamily, contains('Manrope'));
    expect(textField.style?.fontSize, 16);
    expect(textField.style?.fontWeight, FontWeight.w400);
    expect(textField.style?.color, const Color(0xFFA2A2A2));
    expect(textField.decoration?.hintText, 'E-mail');
    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ong@ajudabem.com');
    expect(value, 'ong@ajudabem.com');
  });

  testWidgets('supports obscure password fields with suffix icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppTextField(
            label: 'Senha:',
            hintText: 'Senha',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            suffixIcon: Icon(Icons.visibility_off_outlined),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.obscureText, isTrue);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
