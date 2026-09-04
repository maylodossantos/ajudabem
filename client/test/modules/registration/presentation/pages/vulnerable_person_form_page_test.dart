import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/assisted_person.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/create_assisted_person_params.dart';
import 'package:ajuda_bem/modules/registration/domain/repositories/assisted_person_repository.dart';
import 'package:ajuda_bem/modules/registration/domain/usecases/create_assisted_person_usecase.dart';
import 'package:ajuda_bem/modules/registration/domain/usecases/update_assisted_person_usecase.dart';
import 'package:ajuda_bem/modules/registration/presentation/pages/vulnerable_person_form_page.dart';
import 'package:ajuda_bem/modules/registration/presentation/stores/vulnerable_person_form_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the vulnerability registration form', (tester) async {
    final repository = _FakeAssistedPersonRepository();
    final store = VulnerablePersonFormStore(
      CreateAssistedPersonUsecase(repository),
      UpdateAssistedPersonUsecase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: VulnerablePersonFormPage(store: store, authToken: 'jwt-token'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preencha as informações abaixo'), findsOneWidget);
    expect(
      find.text('Você tem informações pessoais dessa pessoa?'),
      findsOneWidget,
    );
    expect(find.text('Informações Gerais'), findsOneWidget);
    expect(find.text('Nome:'), findsOneWidget);
    expect(find.text('Necessidades identificadas'), findsOneWidget);
    expect(find.text('Como você descreveria essa pessoa?'), findsOneWidget);
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('Reabilitação'), findsOneWidget);
    expect(find.text('Concluir'), findsOneWidget);

    final heading = tester.widget<Text>(
      find.text('Preencha as informações abaixo'),
    );
    expect(heading.style?.fontSize, 16);
    expect(heading.style?.fontWeight, FontWeight.w800);
    expect(heading.style?.color, Colors.black);
    expect(
      tester.getSize(find.byKey(const ValueKey('form-field-Nome:'))).height,
      44,
    );

    var submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('vulnerable_person_submit_button')),
    );
    expect(submitButton.onPressed, isNull);

    store
      ..setHasPersonalInformation(true)
      ..setHasFixedAddress(true)
      ..setName('Maria')
      ..setAge('42')
      ..setSex('Feminino')
      ..setAddress('Rua das Flores')
      ..setCity('Curitiba')
      ..setState('Paraná')
      ..setZipCode('80000-000')
      ..setNumber('123')
      ..setDescription('Pessoa precisando de apoio.')
      ..toggleNeed('Alimentação');
    await tester.pump();

    submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('vulnerable_person_submit_button')),
    );
    expect(submitButton.onPressed, isNotNull);
  });
}

class _FakeAssistedPersonRepository implements AssistedPersonRepository {
  @override
  Future<List<AssistedPerson>> getAll(String token) {
    throw UnimplementedError();
  }

  @override
  Future<AssistedPerson> create(
    CreateAssistedPersonParams params,
    String token,
  ) async {
    return const AssistedPerson(id: 1, fullName: 'Maria');
  }

  @override
  Future<AssistedPerson> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) async {
    return AssistedPerson(id: id, fullName: params.fullName);
  }

  @override
  Future<void> delete(int id, String token) {
    throw UnimplementedError();
  }
}
