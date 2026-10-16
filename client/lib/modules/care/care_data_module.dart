import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import 'data/api_care_repository.dart';
import 'domain/repositories/care_repository.dart';
import 'presentation/stores/care_list_store.dart';

class CareDataModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void exportedBinds(Injector i) {
    i.addSingleton<CareRepository>(ApiCareRepository.new);
    i.add(CareListStore.new);
  }
}
