import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders label, hint and reports input changes', (tester) async {
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

    expect(find.text('E-mail:'), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.emailAddress);
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

  testWidgets('prefills from a controller and supports multiple lines', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Texto inicial');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextField(
            label: 'Conteúdo:',
            hintText: 'Conteúdo',
            controller: controller,
            maxLines: 5,
          ),
        ),
      ),
    );

    expect(find.text('Texto inicial'), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.maxLines, 5);
  });

  testWidgets('disables editing when enabled is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppTextField(hintText: 'E-mail', enabled: false),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
  });
}
