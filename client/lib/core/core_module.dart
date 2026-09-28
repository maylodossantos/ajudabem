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
import 'impact/impact_repository.dart';
import 'impact/impact_store.dart';
import 'notifications/notifications_repository.dart';
import 'notifications/notifications_store.dart';
import 'services/document_picker_service.dart';
import 'services/external_link_service.dart';
import 'services/file_download_service.dart';
import 'services/image_upload_service.dart';
import 'services/location_service.dart';
import 'tags/tags_repository.dart';
import 'tags/tags_store.dart';

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
    i.addSingleton<DocumentPickerService>(FilePickerDocumentService.new);
    i.addSingleton<FileDownloadService>(FileSaverDownloadService.new);
    i.addSingleton<LocationService>(GeolocatorLocationService.new);
    i.addSingleton<ExternalLinkService>(UrlLauncherLinkService.new);
    i.addSingleton(TagsRepository.new);
    i.addSingleton(TagsStore.new);
    i.addSingleton(ImpactRepository.new);
    i.addSingleton(ImpactStore.new);
    i.addSingleton(NotificationsRepository.new);
    i.addSingleton(NotificationsStore.new);
  }
}
