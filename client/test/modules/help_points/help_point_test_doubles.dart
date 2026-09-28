import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/geo/geo_point.dart';
import 'package:ajuda_bem/core/services/location_service.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point_form_params.dart';
import 'package:ajuda_bem/modules/help_points/domain/repositories/help_point_repository.dart';

final monday = DateTime(2026, 9, 28);

const cascavelCenter = GeoPoint(-24.9555, -53.4552);

HelpPoint helpPoint({
  int id = 1,
  String name = 'Albergue Municipal Esperança',
  List<AssistanceType> services = const [AssistanceType.shelter],
  HelpPointOrganizationType organizationType =
      HelpPointOrganizationType.municipalShelter,
  List<OpeningHours> openingHours = const [],
  GeoPoint? location,
  DateTime? createdAt,
}) {
  return HelpPoint(
    id: id,
    name: name,
    organizationType: organizationType,
    services: services,
    street: 'R. Rio Borá',
    city: 'Cascavel',
    state: 'PR',
    openingHours: openingHours,
    location: location,
    createdAt: createdAt ?? DateTime(2026, 1, id),
  );
}

List<OpeningHours> everyDay(int opensAt, int closesAt) => [
  for (var day = DateTime.monday; day <= DateTime.sunday; day++)
    OpeningHours(weekday: day, opensAt: opensAt, closesAt: closesAt),
];

class FakeHelpPointRepository implements HelpPointRepository {
  FakeHelpPointRepository({this.points = const [], this.error});

  List<HelpPoint> points;
  final Object? error;
  HelpPointFormParams? created;
  (int, HelpPointFormParams)? updated;
  int? deleted;

  @override
  Future<List<HelpPoint>> getAll() async {
    if (error != null) throw error!;
    return points;
  }

  @override
  Future<HelpPoint> create(HelpPointFormParams params, String token) async {
    if (error != null) throw error!;
    created = params;
    return helpPoint(id: 99, name: params.name);
  }

  @override
  Future<HelpPoint> update(
    int id,
    HelpPointFormParams params,
    String token,
  ) async {
    if (error != null) throw error!;
    updated = (id, params);
    return helpPoint(id: id, name: params.name);
  }

  @override
  Future<void> delete(int id, String token) async {
    if (error != null) throw error!;
    deleted = id;
  }
}

class FakeLocationService implements LocationService {
  FakeLocationService({this.position, this.errorMessage});

  final GeoPoint? position;
  final String? errorMessage;
  int calls = 0;

  @override
  Future<GeoPoint> currentPosition() async {
    calls++;
    if (errorMessage != null) throw AppException(errorMessage!);
    return position!;
  }
}
