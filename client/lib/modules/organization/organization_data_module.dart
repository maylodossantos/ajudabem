import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import 'data/datasources/organization_datasource.dart';
import 'data/datasources/organization_datasource_impl.dart';
import 'data/repositories/organization_repository_impl.dart';
import 'domain/repositories/organization_repository.dart';
import 'presentation/stores/organization_validation_store.dart';

class OrganizationDataModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void exportedBinds(Injector i) {
    i.addSingleton<OrganizationDatasource>(OrganizationDatasourceImpl.new);
    i.addSingleton<OrganizationRepository>(OrganizationRepositoryImpl.new);
    i.add(OrganizationValidationStore.new);
  }
}
