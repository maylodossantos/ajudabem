import 'package:flutter_modular/flutter_modular.dart';

import '../../core/core_module.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/auth_guard.dart';
import 'data/api_initiative_repositories.dart';
import 'domain/entities/campaign.dart';
import 'domain/entities/volunteer_action.dart';
import 'domain/repositories/initiative_repositories.dart';
import 'presentation/pages/action_detail_page.dart';
import 'presentation/pages/action_form_page.dart';
import 'presentation/pages/action_volunteers_page.dart';
import 'presentation/pages/campaign_detail_page.dart';
import 'presentation/pages/campaign_form_page.dart';
import 'presentation/pages/initiative_chooser_page.dart';
import 'presentation/pages/initiatives_page.dart';
import 'presentation/pages/volunteer_actions_page.dart';
import 'presentation/stores/action_form_store.dart';
import 'presentation/stores/action_stores.dart';
import 'presentation/stores/campaign_form_store.dart';
import 'presentation/stores/campaign_stores.dart';
import 'presentation/stores/initiatives_store.dart';

class InitiativesModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void exportedBinds(Injector i) {
    i.addSingleton<CampaignRepository>(ApiCampaignRepository.new);
    i.addSingleton<VolunteerActionRepository>(ApiVolunteerActionRepository.new);
    i.add(CampaignsFeedStore.new);
  }

  @override
  void binds(Injector i) {
    i.add(InitiativesStore.new);
    i.add(CampaignFormStore.new);
    i.add(ActionFormStore.new);
    i.add(CampaignDetailStore.new);
    i.add(ActionDetailStore.new);
    i.add(VolunteersStore.new);
    i.add(OpenActionsStore.new);
  }

  @override
  void routes(RouteManager r) {
    final guards = [AuthGuard()];
    r.child(
      AppRoutes.initiatives,
      guards: guards,
      child: (_) => const InitiativesPage(),
    );
    r.child(
      AppRoutes.initiativeChooser,
      guards: guards,
      child: (_) => const InitiativeChooserPage(),
    );
    r.child(
      AppRoutes.campaignForm,
      guards: guards,
      child: (_) => CampaignFormPage(
        initial: Modular.args.data is Campaign
            ? Modular.args.data as Campaign
            : null,
      ),
    );
    r.child(
      AppRoutes.actionForm,
      guards: guards,
      child: (_) => ActionFormPage(
        initial: Modular.args.data is VolunteerAction
            ? Modular.args.data as VolunteerAction
            : null,
      ),
    );
    r.child(
      AppRoutes.actionVolunteers,
      guards: guards,
      child: (_) => ActionVolunteersPage(
        actionId: InitiativeArgs.of(Modular.args.data).id,
      ),
    );
    r.child(
      AppRoutes.campaignDetail,
      child: (_) =>
          CampaignDetailPage(args: InitiativeArgs.of(Modular.args.data)),
    );
    r.child(
      AppRoutes.actionDetail,
      guards: guards,
      child: (_) =>
          ActionDetailPage(args: InitiativeArgs.of(Modular.args.data)),
    );
    r.child(
      AppRoutes.volunteerActions,
      guards: guards,
      child: (_) => const VolunteerActionsPage(),
    );
  }
}
