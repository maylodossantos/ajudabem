import '../../domain/entities/assisted_person.dart';
import '../../domain/entities/create_assisted_person_params.dart';
import '../../domain/repositories/assisted_person_repository.dart';
import '../datasources/assisted_person_datasource.dart';

class AssistedPersonRepositoryImpl implements AssistedPersonRepository {
  const AssistedPersonRepositoryImpl(this._datasource);

  final AssistedPersonDatasource _datasource;

  @override
  Future<List<AssistedPerson>> getAll(String token) async {
    final models = await _datasource.getAll(token);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AssistedPerson> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  ) async {
    final model = await _datasource.update(id, params, token);
    return model.toEntity();
  }

  @override
  Future<void> delete(int id, String token) {
    return _datasource.delete(id, token);
  }

  @override
  Future<AssistedPerson> create(
    CreateAssistedPersonParams params,
    String token,
  ) async {
    final model = await _datasource.create(params, token);
    return model.toEntity();
  }
}
