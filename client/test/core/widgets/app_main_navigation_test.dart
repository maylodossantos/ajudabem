import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_bottom_navigation.dart';
import 'package:ajuda_bem/core/widgets/app_main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a visitor sees Notícias, Ajuda and Entrar only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          bottomNavigationBar: AppMainNavigation(
            currentItem: AppNavigationItem.help,
            isSignedIn: false,
          ),
        ),
      ),
    );

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Perfil'), findsNothing);
    expect(find.text('Indicar'), findsNothing);
  });

  testWidgets('a signed-in user sees Perfil and Cadastro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          bottomNavigationBar: AppMainNavigation(
            currentItem: AppNavigationItem.help,
            isSignedIn: true,
          ),
        ),
      ),
    );

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Indicar'), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
  });
}
