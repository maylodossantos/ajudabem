import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/registration/presentation/pages/registration_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the registration menu content and typography', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RegistrationMenuPage()),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Um mundo melhor\nnasce de uma boa\nação.'),
      findsOneWidget,
    );
    expect(find.text('Formulários'), findsOneWidget);
    expect(
      find.text(
        'Informe alguém que precisa de apoio — seja por falta de moradia, '
        'alimento, saúde, dependências ou qualquer outra necessidade urgente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cadastro de Pessoa em Vulnerabilidade'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(
      find.byKey(const Key('registration_menu_bottom_navigation')),
      findsOneWidget,
    );

    final title = tester.widget<Text>(find.text('Formulários'));
    expect(title.style?.fontSize, 16);
    expect(title.style?.fontWeight, FontWeight.w800);
    expect(title.style?.color, Colors.black);

    final bannerText = tester.widget<Text>(
      find.text('Um mundo melhor\nnasce de uma boa\nação.'),
    );
    expect(bannerText.style?.fontSize, 16);
    expect(bannerText.style?.fontWeight, FontWeight.w700);
    expect(bannerText.style?.color, Colors.white);
  });
}
