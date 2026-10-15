import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('never shows a publish tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            currentItem: AppNavigationItem.news,
          ),
        ),
      ),
    );

    expect(find.text('Publicar'), findsNothing);
  });

  testWidgets('shows the Ong tab only for validated NGOs', (tester) async {
    var tapped = false;

    Future<void> pump({required bool showOng}) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            currentItem: AppNavigationItem.ong,
            showOng: showOng,
            onOng: () => tapped = true,
          ),
        ),
      ),
    );

    await pump(showOng: false);
    expect(find.text('Ong'), findsNothing);

    await pump(showOng: true);
    await tester.tap(find.text('Ong'));
    expect(tapped, isTrue);
  });
}
