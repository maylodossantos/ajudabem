import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import 'data/datasources/help_point_datasource.dart';
import 'data/datasources/help_point_datasource_impl.dart';
import 'data/repositories/help_point_repository_impl.dart';
import 'domain/entities/help_point.dart';
import 'domain/entities/help_point_filter.dart';
import 'domain/repositories/help_point_repository.dart';
import 'presentation/pages/help_point_detail_page.dart';
import 'presentation/pages/help_point_filter_page.dart';
import 'presentation/pages/help_point_form_page.dart';
import 'presentation/pages/help_points_page.dart';
import 'presentation/stores/help_point_form_store.dart';
import 'presentation/stores/help_points_store.dart';

class HelpPointsModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<HelpPointDatasource>(HelpPointDatasourceImpl.new);
    i.addSingleton<HelpPointRepository>(HelpPointRepositoryImpl.new);
    i.addSingleton(HelpPointsStore.new);
    i.add(HelpPointFormStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(AppRoutes.helpPoints, child: (_) => const HelpPointsPage());
    r.child(
      AppRoutes.helpPointDetail,
      child: (_) => HelpPointDetailPage(point: Modular.args.data as HelpPoint),
    );
    r.child(
      AppRoutes.helpPointFilter,
      child: (_) {
        final (filter, options) =
            Modular.args.data as (HelpPointFilter, HelpPointOptions);
        return HelpPointFilterPage(initial: filter, options: options);
      },
    );
    r.child(
      AppRoutes.helpPointForm,
      guards: [AuthGuard()],
      child: (_) => HelpPointFormPage(
        initial: Modular.args.data is HelpPoint
            ? Modular.args.data as HelpPoint
            : null,
      ),
    );
  }
}
