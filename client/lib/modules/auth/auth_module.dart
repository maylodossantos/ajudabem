import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;

import '../profile/data/datasources/profile_datasource.dart';
import '../profile/data/datasources/profile_datasource_impl.dart';
import '../profile/data/repositories/profile_repository_impl.dart';
import '../profile/domain/repositories/profile_repository.dart';
import '../profile/domain/usecases/get_current_user_usecase.dart';
import '../profile/presentation/pages/profile_page.dart';
import '../profile/presentation/stores/profile_store.dart';
import '../registration/presentation/pages/registration_menu_page.dart';
import '../registration/presentation/pages/vulnerable_person_form_page.dart';
import '../registration/presentation/stores/assisted_people_store.dart';
import '../registration/presentation/stores/vulnerable_person_form_store.dart';
import '../registration/data/datasources/assisted_person_datasource.dart';
import '../registration/data/datasources/assisted_person_datasource_impl.dart';
import '../registration/data/repositories/assisted_person_repository_impl.dart';
import '../registration/domain/entities/assisted_person.dart';
import '../registration/domain/repositories/assisted_person_repository.dart';
import '../registration/domain/usecases/create_assisted_person_usecase.dart';
import '../registration/domain/usecases/delete_assisted_person_usecase.dart';
import '../registration/domain/usecases/get_assisted_people_usecase.dart';
import '../registration/domain/usecases/update_assisted_person_usecase.dart';
import '../registration/presentation/pages/assisted_people_page.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/datasources/auth_datasource_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/register_user_usecase.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/recover_access_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/stores/login_store.dart';
import 'presentation/stores/recover_access_store.dart';
import 'presentation/stores/register_store.dart';

class AuthModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<http.Client>(http.Client.new);
    i.addSingleton<AuthDatasource>(AuthDatasourceImpl.new);
    i.addSingleton<AuthRepository>(AuthRepositoryImpl.new);
    i.addSingleton<ProfileDatasource>(ProfileDatasourceImpl.new);
    i.addSingleton<ProfileRepository>(ProfileRepositoryImpl.new);
    i.addSingleton<AssistedPersonDatasource>(AssistedPersonDatasourceImpl.new);
    i.addSingleton<AssistedPersonRepository>(AssistedPersonRepositoryImpl.new);
    i.addSingleton(RegisterUserUsecase.new);
    i.addSingleton(SignInUsecase.new);
    i.addSingleton(GetCurrentUserUsecase.new);
    i.addSingleton(CreateAssistedPersonUsecase.new);
    i.addSingleton(GetAssistedPeopleUsecase.new);
    i.addSingleton(UpdateAssistedPersonUsecase.new);
    i.addSingleton(DeleteAssistedPersonUsecase.new);
    i.addSingleton(LoginStore.new);
    i.addSingleton(ProfileStore.new);
    i.add(AssistedPeopleStore.new);
    i.add(VulnerablePersonFormStore.new);
    i.addSingleton(RecoverAccessStore.new);
    i.addSingleton(RegisterStore.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const LoginPage());
    r.child('/recover-access/', child: (_) => const RecoverAccessPage());
    r.child('/register/', child: (_) => const RegisterPage());
    r.child('/profile/', child: (_) => const ProfilePage());
    r.child('/forms/', child: (_) => const RegistrationMenuPage());
    r.child(
      '/forms/vulnerable-person/',
      child: (_) => VulnerablePersonFormPage(
        initialPerson: Modular.args.data is AssistedPerson
            ? Modular.args.data as AssistedPerson
            : null,
      ),
    );
    r.child('/assisted-people/', child: (_) => const AssistedPeoplePage());
  }
}
