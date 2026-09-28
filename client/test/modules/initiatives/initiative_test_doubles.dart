import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/geo/geo_point.dart';
import 'package:ajuda_bem/core/services/external_link_service.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/volunteer_action.dart';
import 'package:ajuda_bem/modules/initiatives/domain/repositories/initiative_repositories.dart';

Campaign campaignWith({
  int id = 1,
  String title = 'Cestas Básicas',
  InitiativeStatus status = InitiativeStatus.active,
  DateTime? deadline,
}) => Campaign(
  id: id,
  title: title,
  description: 'Levar alimento às famílias.',
  donationInfo: 'PIX 111.111.111-11',
  subtitle: '100 cestas',
  category: CampaignCategory.food,
  goalAmount: 1000,
  deadline: deadline,
  status: status,
  organizationName: 'ONG Esperança',
);

VolunteerAction actionWith({
  int id = 1,
  String title = 'Distribuição de alimentos',
  int needed = 6,
  int accepted = 3,
  ApplicationStatus? application,
  InitiativeStatus status = InitiativeStatus.active,
  String? phone,
  String? email,
}) => VolunteerAction(
  id: id,
  title: title,
  date: DateTime(2026, 3, 21),
  startTime: '18:00',
  endTime: '21:00',
  volunteersNeeded: needed,
  acceptedCount: accepted,
  status: status,
  street: 'Praça Wilson Joffre',
  city: 'Cascavel',
  state: 'PR',
  description: 'Entrega de marmitas.',
  tasks: 'Organizar marmitas\nDistribuir alimentos',
  requirements: 'Ter mais de 16 anos',
  organizationName: 'Projeto Mãos que Ajudam',
  myApplication: application,
  contactPhone: phone,
  contactEmail: email,
);

class FakeCampaignRepository implements CampaignRepository {
  FakeCampaignRepository({this.campaigns = const []});

  List<Campaign> campaigns;
  CampaignParams? saved;
  int? savedId;

  @override
  Future<List<Campaign>> active() async => campaigns;

  @override
  Future<Campaign> get(int id) async =>
      campaigns.firstWhere((campaign) => campaign.id == id);

  @override
  Future<List<Campaign>> mine(String token) async => campaigns;

  @override
  Future<Campaign> save(CampaignParams params, String token, {int? id}) async {
    saved = params;
    savedId = id;
    return campaignWith(id: id ?? 99, title: params.title);
  }

  @override
  Future<Campaign> finish(int id, String token) async =>
      campaignWith(id: id, status: InitiativeStatus.finished);
}

class FakeActionRepository implements VolunteerActionRepository {
  FakeActionRepository({this.actions = const [], this.applications = const []});

  List<VolunteerAction> actions;
  List<VolunteerApplication> applications;
  VolunteerActionParams? saved;
  AppException? failure;
  final calls = <String>[];

  VolunteerAction _find(int id) =>
      actions.firstWhere((action) => action.id == id);

  VolunteerAction _update(int id, VolunteerAction Function(VolunteerAction) f) {
    final updated = f(_find(id));
    actions = [for (final item in actions) item.id == id ? updated : item];
    return updated;
  }

  @override
  Future<List<VolunteerAction>> open(String token) async => actions;

  @override
  Future<VolunteerAction> get(int id, String token) async => _find(id);

  @override
  Future<List<VolunteerAction>> mine(String token) async => actions;

  @override
  Future<VolunteerAction> save(
    VolunteerActionParams params,
    String token, {
    int? id,
  }) async {
    saved = params;
    return actionWith(id: id ?? 99, title: params.title);
  }

  @override
  Future<VolunteerAction> finish(int id, String token) async {
    calls.add('finish');
    return _update(
      id,
      (action) => actionWith(id: id, status: InitiativeStatus.finished),
    );
  }

  @override
  Future<VolunteerAction> apply(int id, String token) async {
    if (failure case final error?) throw error;
    calls.add('apply');
    return _update(
      id,
      (action) => action.withApplication(ApplicationStatus.pending),
    );
  }

  @override
  Future<VolunteerAction> withdraw(int id, String token) async {
    calls.add('withdraw');
    return _update(id, (action) => action.withApplication(null));
  }

  @override
  Future<List<VolunteerApplication>> volunteers(int id, String token) async =>
      applications;

  @override
  Future<VolunteerApplication> accept(
    int actionId,
    int applicationId,
    String token,
  ) async {
    if (failure case final error?) throw error;
    final application = applications.firstWhere(
      (item) => item.id == applicationId,
    );
    return VolunteerApplication(
      id: application.id,
      name: application.name,
      phone: application.phone,
      status: ApplicationStatus.accepted,
    );
  }
}

class FakeLinks implements ExternalLinkService {
  final opened = <String>[];

  Future<bool> _open(String link) async {
    opened.add(link);
    return true;
  }

  @override
  Future<bool> call(String phone) => _open('tel:$phone');

  @override
  Future<bool> email(String address) => _open('mailto:$address');

  @override
  Future<bool> openWhatsApp(String phone) => _open('wa:$phone');

  @override
  Future<bool> openMap({GeoPoint? point, required String address}) =>
      _open('map:$address');
}
