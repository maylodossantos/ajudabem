import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_labeled_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a red asterisk only on required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              AppLabeledField(
                label: 'Nome:',
                required: true,
                onChanged: (_) {},
              ),
              AppLabeledField(label: 'Site:', onChanged: (_) {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Nome:'), findsOneWidget);
    expect(find.text('Site:'), findsOneWidget);
    expect(find.text(' *'), findsOneWidget);
  });

  testWidgets('opens a sheet and shows the picked option', (tester) async {
    String? value;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppLabeledDropdown<String>(
              label: 'Área de atuação:',
              hintText: 'Selecione',
              value: value,
              options: const ['Saúde', 'Educação'],
              labelOf: (option) => option,
              onChanged: (option) => setState(() => value = option),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Selecione'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('form-dropdown-Área de atuação:')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Área de atuação'), findsOneWidget);
    await tester.tap(find.text('Educação'));
    await tester.pumpAndSettle();

    expect(value, 'Educação');
    expect(find.text('Selecione'), findsNothing);
    expect(find.text('Educação'), findsOneWidget);
  });
}
