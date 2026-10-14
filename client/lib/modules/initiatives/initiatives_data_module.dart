import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import 'data/api_initiative_repositories.dart';
import 'domain/repositories/initiative_repositories.dart';
import 'presentation/stores/campaign_stores.dart';

class InitiativesDataModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void exportedBinds(Injector i) {
    i.addSingleton<CampaignRepository>(ApiCampaignRepository.new);
    i.addSingleton<VolunteerActionRepository>(ApiVolunteerActionRepository.new);
    i.add(CampaignsFeedStore.new);
  }
}
