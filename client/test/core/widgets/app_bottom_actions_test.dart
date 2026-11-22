import 'package:ajuda_bem/core/widgets/app_card_actions.dart';
import 'package:ajuda_bem/core/widgets/app_page_scaffold.dart';
import 'package:ajuda_bem/core/widgets/app_text_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('a long primary label stays on one line on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Center(
              child: AppBottomActions(
                secondaryLabel: 'Voltar',
                onSecondary: () {},
                primaryLabel: 'Assumir atendimento',
                onPrimary: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final label = find.text('Assumir atendimento');
    expect(label, findsOneWidget);
    expect(tester.widget<Text>(label).maxLines, 1);
    expect(tester.getSize(find.byType(FilledButton)).height, 44);
    expect(tester.getSize(find.byType(OutlinedButton)).height, 44);
  });

  testWidgets('both labels of a card pair share one size', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppCardActions(
              secondaryLabel: 'Ver detalhes',
              onSecondary: () {},
              primaryLabel: 'Assumir atendimento',
              onPrimary: () {},
            ),
          ),
        ),
      ),
    );

    double sizeOf(String label) =>
        tester.widget<Text>(find.text(label)).style!.fontSize!;
    expect(sizeOf('Ver detalhes'), sizeOf('Assumir atendimento'));
  });

  testWidgets('the text dialog saves only a non-empty name', (tester) async {
    String? saved = 'untouched';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => saved = await showAppTextInputDialog(
              context,
              title: 'Renomear',
              fieldKey: const Key('field'),
              confirmKey: const Key('save'),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    FilledButton save() => tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('save')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(save().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('field')), '  Saúde ');
    await tester.pump();
    expect(save().onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    expect(saved, 'Saúde');
  });
}
