import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/assisted_person.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/create_assisted_person_params.dart';
import 'package:ajuda_bem/modules/registration/domain/repositories/assisted_person_repository.dart';
import 'package:ajuda_bem/modules/registration/domain/usecases/delete_assisted_person_usecase.dart';
import 'package:ajuda_bem/modules/registration/domain/usecases/get_assisted_people_usecase.dart';
import 'package:ajuda_bem/modules/registration/presentation/stores/assisted_people_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the registered people', () async {
    final repository = _FakeAssistedPersonRepository();
    final store = _store(repository);

    await store.load('jwt-token');

    expect(repository.receivedToken, 'jwt-token');
    expect(store.people, hasLength(2));
    expect(store.people.first.fullName, 'Maria');
    expect(store.errorMessage, isNull);
    expect(store.isLoading, isFalse);
  });

  test('exposes loading errors', () async {
    final store = AssistedPeopleStore(
      GetAssistedPeopleUsecase(
        _FakeAssistedPersonRepository(
          error: const AppException('Não foi possível carregar os cadastros.'),
        ),
      ),
      DeleteAssistedPersonUsecase(_FakeAssistedPersonRepository()),
    );

    await store.load('jwt-token');

    expect(store.people, isEmpty);
    expect(store.errorMessage, 'Não foi possível carregar os cadastros.');
  });

  test('deletes a registered person and removes it from the list', () async {
    final repository = _FakeAssistedPersonRepository();
    final store = _store(repository);
    await store.load('jwt-token');

    final deleted = await store.deletePerson(1, 'jwt-token');

    expect(deleted, isTrue);
    expect(repository.deletedId, 1);
    expect(store.people.map((person) => person.id), [2]);
  });
}

AssistedPeopleStore _store(_FakeAssistedPersonRepository repository) {
  return AssistedPeopleStore(
    GetAssistedPeopleUsecase(repository),
    DeleteAssistedPersonUsecase(repository),
  );
}

class _FakeAssistedPersonRepository implements AssistedPersonRepository {
  _FakeAssistedPersonRepository({this.error});

  final Object? error;
  String? receivedToken;
  int? deletedId;

  @override
  Future<List<AssistedPerson>> getAll(String token) async {
    receivedToken = token;

    if (error != null) {
      throw error!;
    }

    return const [
      AssistedPerson(id: 1, fullName: 'Maria', riskLevel: 'MEDIUM'),
      AssistedPerson(id: 2, fullName: 'João', riskLevel: 'HIGH'),
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
  Future<void> delete(int id, String token) async {
    deletedId = id;
    receivedToken = token;
  }
}
