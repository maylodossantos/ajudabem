import '../entities/assisted_person.dart';
import '../entities/create_assisted_person_params.dart';
import '../repositories/assisted_person_repository.dart';

class UpdateAssistedPersonUsecase {
  const UpdateAssistedPersonUsecase(this._repository);

  final AssistedPersonRepository _repository;

  Future<AssistedPerson> call(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) {
    return _repository.update(id, params, token);
  }
}
