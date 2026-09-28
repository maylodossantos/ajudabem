import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/entities/care_map.dart';
import '../../domain/repositories/care_repository.dart';

part 'care_map_store.g.dart';

class CareMapStore = CareMapStoreBase with _$CareMapStore;

abstract class CareMapStoreBase with Store {
  CareMapStoreBase(this._repository);

  final CareRepository _repository;

  @observable
  List<CareCase> cases = [];

  @observable
  MapLayer layer = MapLayer.all;

  @observable
  MapMode mode = MapMode.foci;

  @observable
  CareCase? selected;

  @observable
  bool isLoading = false;

  @observable
  bool isAssuming = false;

  @observable
  String? errorMessage;

  @computed
  List<CareCase> get visible => layer.apply(cases);

  @computed
  List<CareFocus> get foci => CareFocus.of(visible);

  @action
  void setLayer(MapLayer value) {
    layer = value;
    if (selected != null && !visible.contains(selected)) selected = null;
  }

  @action
  void toggleMode() {
    mode = mode == MapMode.foci ? MapMode.people : MapMode.foci;
    selected = null;
  }

  @action
  void showPeople() => mode = MapMode.people;

  @action
  void select(CareCase? person) => selected = person;

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;
    try {
      cases = await _repository.map(token);
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar o mapa.',
      );
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> assumeSelected(String token) async {
    final person = selected;
    if (person == null) return false;
    isAssuming = true;
    errorMessage = null;
    try {
      final updated = await _repository.assume(person.id, token);
      cases = [
        for (final item in cases) item.id == updated.id ? updated : item,
      ];
      selected = updated;
      return true;
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível assumir o atendimento.',
      );
      return false;
    } finally {
      isAssuming = false;
    }
  }
}
