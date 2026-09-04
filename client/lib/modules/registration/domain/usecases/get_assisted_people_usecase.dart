import '../entities/assisted_person.dart';
import '../repositories/assisted_person_repository.dart';

class GetAssistedPeopleUsecase {
  const GetAssistedPeopleUsecase(this._repository);

  final AssistedPersonRepository _repository;

  Future<List<AssistedPerson>> call(String token) {
    return _repository.getAll(token);
  }
}
