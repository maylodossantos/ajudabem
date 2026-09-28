import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_bottom_navigation.dart';
import 'package:ajuda_bem/core/widgets/app_main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a visitor is asked to log in before the Cadastro tab', (
    tester,
  ) async {
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

    await tester.tap(find.text('Cadastro'));
    await tester.pump();

    expect(
      find.text('Faça login para acessar o menu de cadastro.'),
      findsOneWidget,
    );
  });
}
