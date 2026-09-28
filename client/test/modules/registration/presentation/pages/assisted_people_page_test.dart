import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/assisted_person.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/create_assisted_person_params.dart';
import 'package:ajuda_bem/modules/registration/domain/repositories/assisted_person_repository.dart';
import 'package:ajuda_bem/modules/registration/presentation/pages/assisted_people_page.dart';
import 'package:ajuda_bem/modules/registration/presentation/stores/assisted_people_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders registered people and their statuses', (tester) async {
    final repository = _FakeAssistedPersonRepository();
    final store = AssistedPeopleStore(repository);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AssistedPeoplePage(store: store, authToken: 'jwt-token'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pessoas cadastradas'), findsOneWidget);
    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('Informações recebidas.'), findsOneWidget);
    expect(find.text('João'), findsOneWidget);
    expect(find.text('Atendimento iniciado'), findsOneWidget);
    expect(find.text('Em triagem'), findsOneWidget);
    expect(find.text('Atendimento finalizado'), findsOneWidget);
    expect(
      find.byKey(const Key('assisted_people_bottom_navigation')),
      findsOneWidget,
    );
    expect(find.byTooltip('Opções do cadastro'), findsNWidgets(4));
  });
}

class _FakeAssistedPersonRepository implements AssistedPersonRepository {
  @override
  Future<List<AssistedPerson>> getAll(String token) async {
    return const [
      AssistedPerson(id: 1, fullName: 'Maria', riskLevel: 'MEDIUM'),
      AssistedPerson(
        id: 2,
        fullName: 'João',
        riskLevel: 'HIGH',
        careStatus: 'IN_CARE',
      ),
      AssistedPerson(id: 3, fullName: 'Ana'),
      AssistedPerson(
        id: 4,
        fullName: 'Pedro',
        riskLevel: 'LOW',
        careStatus: 'FINISHED',
      ),
    ];
  }

  @override
  Future<AssistedPerson> create(
    CreateAssistedPersonParams params,
    String token,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<AssistedPerson> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id, String token) async {}
}
