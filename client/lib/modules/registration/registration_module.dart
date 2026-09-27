import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import 'data/datasources/assisted_person_datasource.dart';
import 'data/datasources/assisted_person_datasource_impl.dart';
import 'data/repositories/assisted_person_repository_impl.dart';
import 'domain/entities/assisted_person.dart';
import 'domain/repositories/assisted_person_repository.dart';
import 'presentation/pages/assisted_people_page.dart';
import 'presentation/pages/registration_menu_page.dart';
import 'presentation/pages/vulnerable_person_form_page.dart';
import 'presentation/stores/assisted_people_store.dart';
import 'presentation/stores/vulnerable_person_form_store.dart';

class RegistrationModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<AssistedPersonDatasource>(AssistedPersonDatasourceImpl.new);
    i.addSingleton<AssistedPersonRepository>(AssistedPersonRepositoryImpl.new);
    i.add(AssistedPeopleStore.new);
    i.add(VulnerablePersonFormStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.registrationMenu,
      child: (_) => const RegistrationMenuPage(),
    );
    r.child(
      AppRoutes.vulnerablePersonRegistration,
      child: (_) => VulnerablePersonFormPage(
        initialPerson: Modular.args.data is AssistedPerson
            ? Modular.args.data as AssistedPerson
            : null,
      ),
    );
    r.child(AppRoutes.assistedPeople, child: (_) => const AssistedPeoplePage());
  }
}
