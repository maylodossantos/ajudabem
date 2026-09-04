import '../repositories/assisted_person_repository.dart';

class DeleteAssistedPersonUsecase {
  const DeleteAssistedPersonUsecase(this._repository);

  final AssistedPersonRepository _repository;

  Future<void> call(int id, String token) {
    return _repository.delete(id, token);
  }
}
