import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_form_params.dart';

abstract interface class HelpPointDatasource {
  Future<List<HelpPoint>> getAll();

  Future<HelpPoint> create(HelpPointFormParams params, String token);

  Future<HelpPoint> update(int id, HelpPointFormParams params, String token);

  Future<void> delete(int id, String token);
}
