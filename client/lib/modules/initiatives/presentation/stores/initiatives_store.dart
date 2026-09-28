import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/volunteer_action.dart';
import '../../domain/repositories/initiative_repositories.dart';

part 'initiatives_store.g.dart';

enum InitiativeTab { campaigns, actions }

class InitiativesStore = InitiativesStoreBase with _$InitiativesStore;

abstract class InitiativesStoreBase with Store {
  InitiativesStoreBase(this._campaigns, this._actions);

  final CampaignRepository _campaigns;
  final VolunteerActionRepository _actions;

  @observable
  List<Campaign> campaigns = [];

  @observable
  List<VolunteerAction> actions = [];

  @observable
  InitiativeTab tab = InitiativeTab.campaigns;

  @observable
  String search = '';

  @observable
  bool isLoading = false;

  @observable
  bool loaded = false;

  @observable
  String? errorMessage;

  @computed
  bool get isEmpty => loaded && campaigns.isEmpty && actions.isEmpty;

  bool _matches(List<String> texts) {
    final term = search.trim().toLowerCase();
    return term.isEmpty ||
        texts.any((text) => text.toLowerCase().contains(term));
  }

  @computed
  List<Campaign> get visibleCampaigns => campaigns
      .where(
        (campaign) => _matches([
          campaign.title,
          campaign.category.label,
          campaign.subtitle,
          campaign.description,
        ]),
      )
      .toList();

  @computed
  List<VolunteerAction> get visibleActions => actions
      .where(
        (action) =>
            _matches([action.title, action.description, action.placeLabel]),
      )
      .toList();

  @action
  void setTab(InitiativeTab value) => tab = value;

  @action
  void setSearch(String value) => search = value;

  @action
  Future<void> load(String token) async {
    isLoading = true;
    errorMessage = null;

    try {
      final results = await Future.wait([
        _campaigns.mine(token),
        _actions.mine(token),
      ]);
      campaigns = results[0] as List<Campaign>;
      actions = results[1] as List<VolunteerAction>;
      loaded = true;
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar as iniciativas.',
      );
    } finally {
      isLoading = false;
    }
  }
}
