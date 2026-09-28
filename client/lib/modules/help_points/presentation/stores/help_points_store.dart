import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/geo/geo_point.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_filter.dart';
import '../../domain/repositories/help_point_repository.dart';

part 'help_points_store.g.dart';

class HelpPointsStore = HelpPointsStoreBase with _$HelpPointsStore;

abstract class HelpPointsStoreBase with Store {
  HelpPointsStoreBase(this._repository, this._locationService);

  final HelpPointRepository _repository;
  final LocationService _locationService;

  @observable
  List<HelpPoint> points = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  HelpPointFilter filter = const HelpPointFilter();

  @observable
  GeoPoint? origin;

  @observable
  bool isLocating = false;

  @observable
  String? locationError;

  @observable
  bool showAsGrid = true;

  @observable
  Set<int> deletingIds = {};

  @observable
  DateTime now = DateTime.now();

  @computed
  List<HelpPoint> get visiblePoints =>
      filter.apply(points, now: now, origin: origin);

  @computed
  HelpPointOptions get options => HelpPointOptions.from(points, now);

  @computed
  bool get isNearbyActive => filter.sort == HelpPointSort.nearest;

  double? distanceKmTo(HelpPoint point) {
    final from = origin;
    final to = point.location;
    return from == null || to == null ? null : from.distanceKmTo(to);
  }

  bool isDeleting(int id) => deletingIds.contains(id);

  bool hasTypes(Set<AssistanceType> types) =>
      types.every(filter.types.contains);

  bool hasOrganizationType(HelpPointOrganizationType type) =>
      filter.organizationTypes.contains(type);

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    now = DateTime.now();

    try {
      points = await _repository.getAll();
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar os pontos de ajuda.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> applyFilter(HelpPointFilter value) async {
    filter = value;
    if (value.needsLocation && origin == null) {
      await locate();
    }
  }

  @action
  Future<void> locate() async {
    isLocating = true;
    locationError = null;

    try {
      origin = await _locationService.currentPosition();
    } on AppException catch (error) {
      locationError = error.message;
    } catch (_) {
      locationError = GeolocatorLocationService.unavailableMessage;
    } finally {
      isLocating = false;
    }
  }

  @action
  Future<void> toggleNearby() => applyFilter(
    filter.copyWith(
      sort: isNearbyActive ? HelpPointSort.recent : HelpPointSort.nearest,
    ),
  );

  @action
  void toggleTypes(Set<AssistanceType> types) {
    final next = Set.of(filter.types);
    if (hasTypes(types)) {
      next.removeAll(types);
    } else {
      next.addAll(types);
    }
    filter = filter.copyWith(types: next);
  }

  @action
  void toggleOrganizationType(HelpPointOrganizationType type) {
    final next = Set.of(filter.organizationTypes);
    if (!next.remove(type)) next.add(type);
    filter = filter.copyWith(organizationTypes: next);
  }

  @action
  void toggleView() => showAsGrid = !showAsGrid;

  @action
  Future<bool> delete(int id, String token) async {
    deletingIds = {...deletingIds, id};
    errorMessage = null;

    try {
      await _repository.delete(id, token);
      points = points.where((point) => point.id != id).toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível excluir o ponto de ajuda.';
      return false;
    } finally {
      deletingIds = Set.of(deletingIds)..remove(id);
    }
  }
}
