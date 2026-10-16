import 'package:ajuda_bem/core/services/cep_service.dart';
import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/core/widgets/app_cep_field.dart';
import 'package:ajuda_bem/core/widgets/app_labeled_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fills the address fields once the CEP is complete', (
    tester,
  ) async {
    var street = '';
    var city = '';
    String? state;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                AppCepField(
                  initialValue: '',
                  onChanged: (_) {},
                  service: _FakeCepService(),
                  onStreet: (value) => setState(() => street = value),
                  onCity: (value) => setState(() => city = value),
                  onState: (value) => setState(() => state = value),
                ),
                AppLabeledField(
                  label: 'Endereço:',
                  initialValue: street,
                  onChanged: (value) => street = value,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, '85801000');
    await tester.pumpAndSettle();

    expect(street, 'Avenida Brasil');
    expect(city, 'Cascavel');
    expect(state, 'PR');
    expect(find.text('Avenida Brasil'), findsOneWidget);
  });

  testWidgets('warns when the CEP is not found', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppCepField(
            initialValue: '',
            onChanged: (_) {},
            service: _FakeCepService(found: false),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '00000000');
    await tester.pumpAndSettle();

    expect(
      find.text('CEP não encontrado. Preencha o endereço.'),
      findsOneWidget,
    );
  });
}

class _FakeCepService implements CepService {
  _FakeCepService({this.found = true});

  final bool found;

  @override
  Future<CepAddress?> lookup(String cep) async => found
      ? const CepAddress(
          street: 'Avenida Brasil',
          neighborhood: 'Centro',
          city: 'Cascavel',
          state: 'PR',
        )
      : null;
}
