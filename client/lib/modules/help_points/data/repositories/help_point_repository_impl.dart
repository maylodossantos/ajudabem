import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_form_params.dart';
import '../../domain/repositories/help_point_repository.dart';
import '../datasources/help_point_datasource.dart';

class HelpPointRepositoryImpl implements HelpPointRepository {
  const HelpPointRepositoryImpl(this._datasource);

  final HelpPointDatasource _datasource;

  @override
  Future<List<HelpPoint>> getAll() => _datasource.getAll();

  @override
  Future<HelpPoint> create(HelpPointFormParams params, String token) =>
      _datasource.create(params, token);

  @override
  Future<HelpPoint> update(int id, HelpPointFormParams params, String token) =>
      _datasource.update(id, params, token);

  @override
  Future<void> delete(int id, String token) => _datasource.delete(id, token);
}
