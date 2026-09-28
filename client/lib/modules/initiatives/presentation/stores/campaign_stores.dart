import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/initiative_repositories.dart';

part 'campaign_stores.g.dart';

class CampaignDetailStore = CampaignDetailStoreBase with _$CampaignDetailStore;

abstract class CampaignDetailStoreBase with Store {
  CampaignDetailStoreBase(this._repository);

  final CampaignRepository _repository;

  @observable
  Campaign? campaign;

  @observable
  bool isLoading = false;

  @observable
  bool isFinishing = false;

  @observable
  String? errorMessage;

  @action
  void show(Campaign value) => campaign = value;

  @action
  Future<void> load(int id) async {
    isLoading = true;
    errorMessage = null;
    try {
      campaign = await _repository.get(id);
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar a campanha.',
      );
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> finish(String token) async {
    final current = campaign;
    if (current == null) return false;
    isFinishing = true;
    errorMessage = null;
    try {
      campaign = await _repository.finish(current.id, token);
      return true;
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível finalizar a campanha.',
      );
      return false;
    } finally {
      isFinishing = false;
    }
  }
}

class CampaignsFeedStore = CampaignsFeedStoreBase with _$CampaignsFeedStore;

abstract class CampaignsFeedStoreBase with Store {
  CampaignsFeedStoreBase(this._repository);

  final CampaignRepository _repository;

  @observable
  List<Campaign> campaigns = [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    try {
      campaigns = await _repository.active();
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível carregar as campanhas.',
      );
    } finally {
      isLoading = false;
    }
  }
}
