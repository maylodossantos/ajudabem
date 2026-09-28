import 'package:flutter_modular/flutter_modular.dart';

import 'modules/auth/auth_module.dart';
import 'modules/care/care_module.dart';
import 'modules/help_points/help_points_module.dart';
import 'modules/initiatives/initiatives_module.dart';
import 'modules/news/news_module.dart';
import 'modules/notifications/notifications_module.dart';
import 'modules/organization/organization_module.dart';
import 'modules/profile/profile_module.dart';
import 'modules/registration/registration_module.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module('/', module: AuthModule());
    r.module('/', module: NewsModule());
    r.module('/', module: ProfileModule());
    r.module('/', module: RegistrationModule());
    r.module('/', module: OrganizationModule());
    r.module('/', module: HelpPointsModule());
    r.module('/', module: CareModule());
    r.module('/', module: InitiativesModule());
    r.module('/', module: NotificationsModule());
  }
}
