import '../entities/assisted_person.dart';
import '../entities/create_assisted_person_params.dart';

abstract interface class AssistedPersonRepository {
  Future<AssistedPerson> create(
    CreateAssistedPersonParams params,
    String token,
  );

  Future<List<AssistedPerson>> getAll(String token);

  Future<AssistedPerson> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  );

  Future<void> delete(int id, String token);
}
