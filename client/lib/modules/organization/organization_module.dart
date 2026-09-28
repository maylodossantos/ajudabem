import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import '../care/care_module.dart';
import 'data/datasources/organization_datasource.dart';
import 'data/datasources/organization_datasource_impl.dart';
import 'data/repositories/organization_repository_impl.dart';
import 'domain/entities/organization.dart';
import 'domain/repositories/organization_repository.dart';
import 'presentation/pages/document_viewer_page.dart';
import 'presentation/pages/ong_home_page.dart';
import 'presentation/pages/ong_review_detail_page.dart';
import 'presentation/pages/ong_review_list_page.dart';
import 'presentation/pages/ong_validation_form_page.dart';
import 'presentation/pages/ong_validation_page.dart';
import 'presentation/stores/organization_form_store.dart';
import 'presentation/stores/organization_review_list_store.dart';
import 'presentation/stores/organization_review_store.dart';
import 'presentation/stores/organization_validation_store.dart';

class OrganizationModule extends Module {
  @override
  List<Module> get imports => [CoreModule(), CareModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<OrganizationDatasource>(OrganizationDatasourceImpl.new);
    i.addSingleton<OrganizationRepository>(OrganizationRepositoryImpl.new);
    i.add(OrganizationValidationStore.new);
    i.add(OrganizationFormStore.new);
    i.add(OrganizationReviewListStore.new);
    i.add(OrganizationReviewStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.ong,
      guards: [AuthGuard()],
      child: (_) => const OngHomePage(),
    );
    r.child(
      AppRoutes.ongValidation,
      guards: [AuthGuard()],
      child: (_) => const OngValidationPage(),
    );
    r.child(
      AppRoutes.ongValidationForm,
      guards: [AuthGuard()],
      child: (_) => OngValidationFormPage(
        previous: Modular.args.data is Organization
            ? Modular.args.data as Organization
            : null,
      ),
    );
    r.child(
      AppRoutes.ongReviews,
      guards: [AuthGuard()],
      child: (_) => const OngReviewListPage(),
    );
    r.child(
      AppRoutes.ongReviewDetail,
      guards: [AuthGuard()],
      child: (_) =>
          OngReviewDetailPage(organization: Modular.args.data as Organization),
    );
    r.child(
      AppRoutes.documentViewer,
      guards: [AuthGuard()],
      child: (_) =>
          DocumentViewerPage(args: Modular.args.data as DocumentViewerArgs),
    );
  }
}
