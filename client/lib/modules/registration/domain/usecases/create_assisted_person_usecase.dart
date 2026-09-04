import '../entities/assisted_person.dart';
import '../entities/create_assisted_person_params.dart';
import '../repositories/assisted_person_repository.dart';

class CreateAssistedPersonUsecase {
  const CreateAssistedPersonUsecase(this._repository);

  final AssistedPersonRepository _repository;

  Future<AssistedPerson> call(CreateAssistedPersonParams params, String token) {
    return _repository.create(params, token);
  }
}
