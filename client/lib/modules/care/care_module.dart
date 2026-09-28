import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import 'data/api_care_repository.dart';
import 'domain/entities/care_case.dart';
import 'domain/entities/care_filter.dart';
import 'domain/repositories/care_repository.dart';
import 'presentation/pages/care_case_page.dart';
import 'presentation/pages/care_filter_page.dart';
import 'presentation/pages/care_list_page.dart';
import 'presentation/pages/care_map_page.dart';
import 'presentation/pages/care_record_form_page.dart';
import 'presentation/stores/care_case_store.dart';
import 'presentation/stores/care_list_store.dart';
import 'presentation/stores/care_map_store.dart';
import 'presentation/stores/care_record_form_store.dart';

class CareModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void exportedBinds(Injector i) {
    i.addSingleton<CareRepository>(ApiCareRepository.new);
    i.add(CareListStore.new);
  }

  @override
  void binds(Injector i) {
    i.add(CareCaseStore.new);
    i.add(CareRecordFormStore.new);
    i.add(CareMapStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.nominatedPeople,
      guards: [AuthGuard()],
      child: (_) => CareListPage(
        mode: CareListMode.nominated,
        initialFilter: Modular.args.data is CareFilter
            ? Modular.args.data as CareFilter
            : null,
      ),
    );
    r.child(
      AppRoutes.peopleInCare,
      guards: [AuthGuard()],
      child: (_) => const CareListPage(mode: CareListMode.myCases),
    );
    r.child(
      AppRoutes.careCase,
      guards: [AuthGuard()],
      child: (_) => CareCasePage(personId: Modular.args.data as int),
    );
    r.child(
      AppRoutes.careRecord,
      guards: [AuthGuard()],
      child: (_) =>
          CareRecordFormPage(detail: Modular.args.data as CareCaseDetail),
    );
    r.child(
      AppRoutes.careMap,
      guards: [AuthGuard()],
      child: (_) => const CareMapPage(),
    );
    r.child(
      AppRoutes.careFilter,
      guards: [AuthGuard()],
      child: (_) {
        final (filter, options, mode) =
            Modular.args.data as (CareFilter, CareOptions, CareListMode);
        return CareFilterPage(initial: filter, options: options, mode: mode);
      },
    );
  }
}
