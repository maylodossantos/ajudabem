import 'package:ajuda_bem/modules/registration/domain/entities/assisted_person.dart';
import 'package:ajuda_bem/modules/registration/domain/entities/create_assisted_person_params.dart';
import 'package:ajuda_bem/modules/registration/domain/repositories/assisted_person_repository.dart';
import 'package:ajuda_bem/modules/registration/domain/usecases/create_assisted_person_usecase.dart';
import 'package:ajuda_bem/modules/registration/domain/usecases/update_assisted_person_usecase.dart';
import 'package:ajuda_bem/modules/registration/presentation/stores/vulnerable_person_form_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates personal information and address choices', () {
    final store = _store();

    store.setHasPersonalInformation(true);
    store.setHasFixedAddress(false);
    store.setSex('Feminino');
    store.setState('São Paulo');

    expect(store.hasPersonalInformation, isTrue);
    expect(store.hasFixedAddress, isFalse);
    expect(store.sex, 'Feminino');
    expect(store.state, 'São Paulo');
  });

  test('allows selecting multiple identified needs', () {
    final store = _store();

    store.toggleNeed('Alimentação');
    store.toggleNeed('Moradia');

    expect(store.isNeedSelected('Alimentação'), isTrue);
    expect(store.isNeedSelected('Moradia'), isTrue);

    store.toggleNeed('Alimentação');

    expect(store.isNeedSelected('Alimentação'), isFalse);
    expect(store.isNeedSelected('Moradia'), isTrue);
  });

  test('enables submission only when the form is complete', () {
    final store = _store();

    expect(store.canSubmit, isFalse);

    _fillRequiredFields(store);

    expect(store.canSubmit, isTrue);

    store.setDescription('');

    expect(store.canSubmit, isFalse);
  });

  test('submits the form using the existing backend contract', () async {
    final repository = _FakeAssistedPersonRepository();
    final store = _store(repository);
    _fillRequiredFields(store);
    store
      ..setSex('Feminino')
      ..toggleNeed('Saúde');

    final success = await store.submit('jwt-token');

    expect(success, isTrue);
    expect(repository.receivedToken, 'jwt-token');
    expect(repository.receivedParams?.fullName, 'Maria');
    expect(repository.receivedParams?.age, 42);
    expect(repository.receivedParams?.gender, 'FEMALE');
    expect(repository.receivedParams?.tagIds, [1, 3]);
    expect(repository.receivedParams?.street, 'Rua das Flores');
    expect(repository.receivedParams?.neighborhood, isEmpty);
    expect(repository.receivedParams?.country, 'Brasil');
  });

  test('updates an existing registered person', () async {
    final repository = _FakeAssistedPersonRepository();
    final store = _store(repository);
    store.populate(
      const AssistedPerson(
        id: 7,
        fullName: 'Maria',
        age: 42,
        gender: 'FEMALE',
        tags: ['Alimentação'],
        notes: 'Precisa de apoio.',
        street: 'Rua das Flores',
        number: '123',
        city: 'Curitiba',
        state: 'Paraná',
        zipCode: '80000-000',
      ),
    );
    store.setName('Maria Silva');

    final success = await store.submit('jwt-token');

    expect(success, isTrue);
    expect(repository.updatedId, 7);
    expect(repository.receivedParams?.fullName, 'Maria Silva');
  });
}

VulnerablePersonFormStore _store([_FakeAssistedPersonRepository? repository]) {
  final assistedPersonRepository =
      repository ?? _FakeAssistedPersonRepository();
  return VulnerablePersonFormStore(
    CreateAssistedPersonUsecase(assistedPersonRepository),
    UpdateAssistedPersonUsecase(assistedPersonRepository),
  );
}

void _fillRequiredFields(VulnerablePersonFormStore store) {
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
}

class _FakeAssistedPersonRepository implements AssistedPersonRepository {
  CreateAssistedPersonParams? receivedParams;
  String? receivedToken;
  int? updatedId;

  @override
  Future<List<AssistedPerson>> getAll(String token) {
    throw UnimplementedError();
  }

  @override
  Future<AssistedPerson> create(
    CreateAssistedPersonParams params,
    String token,
  ) async {
    receivedParams = params;
    receivedToken = token;
    return const AssistedPerson(id: 1, fullName: 'Maria');
  }

  @override
  Future<AssistedPerson> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) async {
    updatedId = id;
    receivedParams = params;
    receivedToken = token;
    return AssistedPerson(id: id, fullName: params.fullName);
  }

  @override
  Future<void> delete(int id, String token) {
    throw UnimplementedError();
  }
}
