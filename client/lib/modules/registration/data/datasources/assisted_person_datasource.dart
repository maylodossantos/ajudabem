import '../../domain/entities/create_assisted_person_params.dart';
import '../models/assisted_person_model.dart';

abstract interface class AssistedPersonDatasource {
  Future<AssistedPersonModel> create(
    CreateAssistedPersonParams params,
    String token,
  );

  Future<List<AssistedPersonModel>> getAll(String token);

  Future<AssistedPersonModel> update(
    int id,
    CreateAssistedPersonParams params,
    String token,
  );

  Future<void> delete(int id, String token);
}
