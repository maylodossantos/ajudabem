import 'package:ajuda_bem/app_module.dart';
import 'package:ajuda_bem/app_widget.dart';
import 'package:ajuda_bem/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows login screen content and visual tokens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ModularApp(module: AppModule(), child: const AppWidget()),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Seja bem-vindo ao AjudaBem!'), findsOneWidget);
    expect(find.text('E-mail:'), findsOneWidget);
    expect(find.text('Senha:'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Ou'), findsOneWidget);
    expect(find.text('Faça login com o Google'), findsOneWidget);
    expect(find.text('Faça login com o Facebook'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byKey(const Key('login_bottom_navigation')), findsOneWidget);
    expect(find.text('Notícias'), findsOneWidget);
    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF3F3F3));

    final welcome = tester.widget<Text>(
      find.text('Seja bem-vindo ao AjudaBem!'),
    );
    expect(welcome.style?.fontFamily, contains('Manrope'));
    expect(welcome.style?.fontSize, 16);
    expect(welcome.style?.fontWeight, FontWeight.w700);
    expect(welcome.style?.letterSpacing, 0);
    expect(welcome.style?.color, const Color(0xFF04957C));

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(
      find.text('Faça login para acessar o menu de cadastro.'),
      findsOneWidget,
    );
    expect(find.text('Seja bem-vindo ao AjudaBem!'), findsOneWidget);

    final enter = tester.widget<Text>(find.text('Entrar'));
    expect(enter.style?.fontFamily, contains('Manrope'));
    expect(enter.style?.fontSize, 16);
    expect(enter.style?.fontWeight, FontWeight.w700);
    expect(enter.style?.color, Colors.white);

    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Crie sua conta no AjudaBem.'), findsOneWidget);
    expect(find.text('Nome:'), findsOneWidget);
    expect(find.text('Telefone:'), findsOneWidget);
    expect(find.text('Confirme sua senha:'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.byType(SvgPicture), findsWidgets);
    expect(find.byKey(const Key('login_bottom_navigation')), findsNothing);

    Modular.to.navigate(AppRoutes.auth);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Esqueci minha senha'));
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    expect(find.text('Esqueceu sua senha?'), findsOneWidget);
    expect(find.text('Digite seu e-mail'), findsOneWidget);
    expect(find.text('Enviar código'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byTooltip('Voltar'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Seja bem-vindo ao AjudaBem!'), findsOneWidget);
  });
}
