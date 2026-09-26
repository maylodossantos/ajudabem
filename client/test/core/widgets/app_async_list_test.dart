import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_async_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    List<String> items = const [],
    bool isLoading = false,
    String? errorMessage,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppAsyncList<String>(
            items: items,
            isLoading: isLoading,
            errorMessage: errorMessage,
            emptyMessage: 'Nada por aqui.',
            onRefresh: () async {},
            itemBuilder: (_, item) => Text(item),
          ),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while the first load is running', (
    tester,
  ) async {
    await pump(tester, isLoading: true);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error with a retry when nothing loaded', (
    tester,
  ) async {
    await pump(tester, errorMessage: 'Sem conexão.');

    expect(find.text('Sem conexão.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('shows the empty message when there are no items', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Nada por aqui.'), findsOneWidget);
  });

  testWidgets('keeps showing loaded items during a refresh or error', (
    tester,
  ) async {
    await pump(
      tester,
      items: ['Maria', 'João'],
      isLoading: true,
      errorMessage: 'Falhou.',
    );

    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('João'), findsOneWidget);
    expect(find.text('Falhou.'), findsNothing);
  });
}
