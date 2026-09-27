import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/auth/domain/repositories/auth_repository.dart';
import 'package:ajuda_bem/modules/auth/domain/usecases/register_user_usecase.dart';
import 'package:ajuda_bem/modules/auth/presentation/pages/terms_of_use_page.dart';
import 'package:ajuda_bem/modules/auth/presentation/stores/register_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openTerms(WidgetTester tester, RegisterStore store) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TermsOfUsePage(store: store),
              ),
            ),
            child: const Text('Abrir termos'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir termos'));
    await tester.pumpAndSettle();
  }

  testWidgets('accepting marks the terms and goes back', (tester) async {
    final store = RegisterStore(RegisterUserUsecase(_UnusedAuthRepository()));
    await openTerms(tester, store);

    await tester.tap(find.byKey(const Key('terms_accept_button')));
    await tester.pumpAndSettle();

    expect(store.acceptedTerms, isTrue);
    expect(find.byType(TermsOfUsePage), findsNothing);
  });

  testWidgets('declining unmarks the terms and goes back', (tester) async {
    final store = RegisterStore(RegisterUserUsecase(_UnusedAuthRepository()))
      ..setAcceptedTerms(true);
    await openTerms(tester, store);

    await tester.tap(find.byKey(const Key('terms_decline_button')));
    await tester.pumpAndSettle();

    expect(store.acceptedTerms, isFalse);
    expect(find.byType(TermsOfUsePage), findsNothing);
  });
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
