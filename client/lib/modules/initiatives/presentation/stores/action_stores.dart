import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/volunteer_action.dart';
import '../../domain/repositories/initiative_repositories.dart';

part 'action_stores.g.dart';

class ActionDetailStore = ActionDetailStoreBase with _$ActionDetailStore;

abstract class ActionDetailStoreBase with Store {
  ActionDetailStoreBase(this._repository);

  final VolunteerActionRepository _repository;

  @observable
  VolunteerAction? current;

  @observable
  bool isLoading = false;

  @observable
  bool isBusy = false;

  @observable
  String? errorMessage;

  @action
  Future<void> load(int id, String token) async {
    isLoading = true;
    errorMessage = null;
    try {
      current = await _repository.get(id, token);
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar a ação.',
      );
    } finally {
      isLoading = false;
    }
  }

  Future<bool> _change(
    Future<VolunteerAction> Function(int id) run,
    String fallback,
  ) async {
    final selected = current;
    if (selected == null) return false;
    runInAction(() {
      isBusy = true;
      errorMessage = null;
    });
    try {
      final updated = await run(selected.id);
      runInAction(() => current = updated);
      return true;
    } catch (error) {
      runInAction(() => errorMessage = AppException.messageOf(error, fallback));
      return false;
    } finally {
      runInAction(() => isBusy = false);
    }
  }

  Future<bool> apply(String token) => _change(
    (id) => _repository.apply(id, token),
    'Não foi possível enviar sua candidatura.',
  );

  Future<bool> withdraw(String token) => _change(
    (id) => _repository.withdraw(id, token),
    'Não foi possível cancelar sua candidatura.',
  );

  Future<bool> finish(String token) => _change(
    (id) => _repository.finish(id, token),
    'Não foi possível finalizar a ação.',
  );
}

class VolunteersStore = VolunteersStoreBase with _$VolunteersStore;

abstract class VolunteersStoreBase with Store {
  VolunteersStoreBase(this._repository);

  final VolunteerActionRepository _repository;

  @observable
  VolunteerAction? current;

  @observable
  List<VolunteerApplication> volunteers = [];

  @observable
  bool isLoading = false;

  @observable
  Set<int> acceptingIds = {};

  @observable
  String? errorMessage;

  @computed
  int get acceptedCount => volunteers.where((item) => item.isAccepted).length;

  bool isAccepting(int id) => acceptingIds.contains(id);

  @action
  Future<void> load(int actionId, String token) async {
    isLoading = true;
    errorMessage = null;
    try {
      final results = await Future.wait([
        _repository.get(actionId, token),
        _repository.volunteers(actionId, token),
      ]);
      current = results[0] as VolunteerAction;
      volunteers = results[1] as List<VolunteerApplication>;
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar os voluntários.',
      );
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> accept(VolunteerApplication application, String token) async {
    final selected = current;
    if (selected == null) return false;
    acceptingIds = {...acceptingIds, application.id};
    errorMessage = null;
    try {
      final accepted = await _repository.accept(
        selected.id,
        application.id,
        token,
      );
      volunteers = [
        for (final item in volunteers) item.id == accepted.id ? accepted : item,
      ];
      return true;
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível aceitar o voluntário.',
      );
      return false;
    } finally {
      acceptingIds = Set.of(acceptingIds)..remove(application.id);
    }
  }
}

class OpenActionsStore = OpenActionsStoreBase with _$OpenActionsStore;

abstract class OpenActionsStoreBase with Store {
  OpenActionsStoreBase(this._repository);

  final VolunteerActionRepository _repository;

  @observable
  List<VolunteerAction> actions = [];

  @observable
  String search = '';

  @observable
  bool isLoading = false;

  @observable
  Set<int> applyingIds = {};

  @observable
  String? errorMessage;

  @computed
  List<VolunteerAction> get visibleActions {
    final term = search.trim().toLowerCase();
    if (term.isEmpty) return actions;
    return actions
        .where(
          (action) => [
            action.title,
            action.placeLabel,
            action.organizationName,
            action.description,
          ].any((text) => text.toLowerCase().contains(term)),
        )
        .toList();
  }

  bool isApplying(int id) => applyingIds.contains(id);

  @action
  void setSearch(String value) => search = value;

  @action
  void replace(VolunteerAction updated) {
    actions = [
      for (final item in actions) item.id == updated.id ? updated : item,
    ];
  }

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;
    try {
      actions = await _repository.open(token);
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar as ações.',
      );
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> apply(VolunteerAction action, String token) async {
    applyingIds = {...applyingIds, action.id};
    errorMessage = null;
    try {
      replace(await _repository.apply(action.id, token));
      return true;
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível enviar sua candidatura.',
      );
      return false;
    } finally {
      applyingIds = Set.of(applyingIds)..remove(action.id);
    }
  }
}
