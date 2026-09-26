import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hides the publish tab by default', (tester) async {
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

  testWidgets('shows the publish tab and reports taps when enabled', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            currentItem: AppNavigationItem.news,
            showCreateNews: true,
            onCreateNews: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Publicar'), findsOneWidget);

    await tester.tap(find.text('Publicar'));
    expect(tapped, isTrue);
  });
}
