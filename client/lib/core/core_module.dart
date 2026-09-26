import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;

import '../modules/auth/data/datasources/auth_datasource.dart';
import '../modules/auth/data/datasources/auth_datasource_impl.dart';
import '../modules/auth/data/repositories/auth_repository_impl.dart';
import '../modules/auth/domain/repositories/auth_repository.dart';
import '../modules/auth/domain/usecases/sign_in_usecase.dart';
import '../modules/auth/presentation/stores/login_store.dart';
import '../modules/profile/data/datasources/profile_datasource.dart';
import '../modules/profile/data/datasources/profile_datasource_impl.dart';
import '../modules/profile/data/repositories/profile_repository_impl.dart';
import '../modules/profile/domain/repositories/profile_repository.dart';
import '../modules/profile/presentation/stores/profile_store.dart';
import 'services/image_upload_service.dart';

/// Bindings shared across feature modules: the HTTP client every datasource
/// needs, the session (LoginStore) that every module reads for the current
/// user's token, the current user's profile (ProfileStore - e.g. the News
/// module reads `profile.canPublishNews` to gate the publish icon by role),
/// and the image upload service (imgbb) that photo uploads go through.
///
/// This is imported (`imports: [CoreModule()]`) by every module that needs
/// one of these, never mounted with `r.module()`. flutter_modular's
/// per-module injector can only resolve a bind's constructor parameters
/// against binds declared in the SAME module or a module it imports - never
/// "upward" into whichever module mounted it, regardless of eager
/// (`addSingleton`) vs lazy (`add`). A bind other modules need to consume has
/// to live in something they import, declared via `exportedBinds` (`binds`
/// only registers for the module that owns it).
class CoreModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addSingleton<http.Client>(http.Client.new);
    i.addSingleton<AuthDatasource>(AuthDatasourceImpl.new);
    i.addSingleton<AuthRepository>(AuthRepositoryImpl.new);
    i.addSingleton(SignInUsecase.new);
    i.addSingleton(LoginStore.new);
    i.addSingleton<ProfileDatasource>(ProfileDatasourceImpl.new);
    i.addSingleton<ProfileRepository>(ProfileRepositoryImpl.new);
    i.addSingleton(ProfileStore.new);
    i.addSingleton<ImageUploadService>(ImgbbImageUploadService.new);
  }
}
