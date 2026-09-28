import 'package:http/http.dart' as http;

import '../../../core/formatters/date_input_formatter.dart';
import '../../../core/network/api_requester.dart';
import '../domain/entities/campaign.dart';
import '../domain/entities/volunteer_action.dart';
import '../domain/repositories/initiative_repositories.dart';

const _sessionExpiredStatuses = {401};

const _serverMessages = {
  'Initiative already finished': 'Esta iniciativa já foi finalizada.',
  'Already applied to this action': 'Você já se candidatou para esta ação.',
  'No vacancies left': 'Não há mais vagas nesta ação.',
  'Organizations cannot apply to their own actions':
      'Sua ONG não pode se candidatar à própria ação.',
  'Only approved organizations can do this':
      'Só ONGs aprovadas podem fazer isso.',
  'Only the organization in charge can do this':
      'Só a ONG responsável pode fazer isso.',
};

String? _text(String value) => value.trim().isEmpty ? null : value.trim();

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String _time(Object? value) =>
    value is String && value.length >= 5 ? value.substring(0, 5) : '';

String _organizationName(Map<String, dynamic> json) {
  final organization = json['organization'];
  return organization is Map<String, dynamic>
      ? organization['tradeName'] as String? ?? ''
      : '';
}

class ApiCampaignRepository implements CampaignRepository {
  ApiCampaignRepository(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static Campaign fromJson(Map<String, dynamic> json) => Campaign(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    donationInfo: json['donationInfo'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: CampaignCategory.fromApi(json['category'] as String?),
    goalAmount: (json['goalAmount'] as num?)?.toDouble(),
    deadline: _date(json['deadline']),
    coverImage: json['coverImage'] as String?,
    status: InitiativeStatus.fromApi(json['status'] as String?),
    organizationName: _organizationName(json),
  );

  Campaign _decode(http.Response response) =>
      fromJson(ApiRequester.decodeObject(response));

  @override
  Future<List<Campaign>> active() {
    return _api.request(
      HttpMethod.get,
      '/campaign',
      errorMessage: 'Não foi possível carregar as campanhas.',
      useServerMessage: false,
      onSuccess: (response) =>
          ApiRequester.decodeList(response).map(fromJson).toList(),
    );
  }

  @override
  Future<Campaign> get(int id) {
    return _api.request(
      HttpMethod.get,
      '/campaign/$id',
      errorMessage: 'Não foi possível carregar a campanha.',
      useServerMessage: false,
      onSuccess: _decode,
    );
  }

  @override
  Future<List<Campaign>> mine(String token) {
    return _api.request(
      HttpMethod.get,
      '/campaign/mine',
      token: token,
      errorMessage: 'Não foi possível carregar as campanhas.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          ApiRequester.decodeList(response).map(fromJson).toList(),
    );
  }

  @override
  Future<Campaign> save(CampaignParams params, String token, {int? id}) {
    final deadline = params.deadline;
    return _api.request(
      id == null ? HttpMethod.post : HttpMethod.put,
      id == null ? '/campaign' : '/campaign/$id',
      token: token,
      body: {
        'title': params.title.trim(),
        'donationInfo': _text(params.donationInfo),
        'subtitle': _text(params.subtitle),
        'description': params.description.trim(),
        'category': params.category.apiValue,
        'goalAmount': params.goalAmount,
        'deadline': deadline == null
            ? null
            : DateInputFormatter.toIso(deadline),
        'coverImage': params.coverImage,
      },
      errorMessage: 'Não foi possível salvar a campanha.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  @override
  Future<Campaign> finish(int id, String token) {
    return _api.request(
      HttpMethod.post,
      '/campaign/$id/finish',
      token: token,
      errorMessage: 'Não foi possível finalizar a campanha.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }
}

class ApiVolunteerActionRepository implements VolunteerActionRepository {
  ApiVolunteerActionRepository(http.Client client)
    : _api = ApiRequester(client);

  final ApiRequester _api;

  static VolunteerAction fromJson(Map<String, dynamic> json) {
    final contact = json['contact'];
    return VolunteerAction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      date: _date(json['date']) ?? DateTime.now(),
      startTime: _time(json['startTime']),
      endTime: _time(json['endTime']),
      volunteersNeeded: (json['volunteersNeeded'] as num?)?.toInt() ?? 0,
      acceptedCount: (json['acceptedCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tasks: json['tasks'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: InitiativeStatus.fromApi(json['status'] as String?),
      organizationName: _organizationName(json),
      myApplication: ApplicationStatus.fromApi(
        json['myApplication'] as String?,
      ),
      contactPhone: contact is Map<String, dynamic>
          ? contact['phone'] as String?
          : null,
      contactEmail: contact is Map<String, dynamic>
          ? contact['email'] as String?
          : null,
    );
  }

  static VolunteerApplication applicationFromJson(Map<String, dynamic> json) =>
      VolunteerApplication(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        profileImage: json['profileImage'] as String?,
        phone: json['phone'] as String?,
        status:
            ApplicationStatus.fromApi(json['status'] as String?) ??
            ApplicationStatus.pending,
      );

  VolunteerAction _decode(http.Response response) =>
      fromJson(ApiRequester.decodeObject(response));

  Future<T> _call<T>(
    HttpMethod method,
    String path,
    String token,
    String error,
    T Function(http.Response) onSuccess, {
    Object? body,
  }) {
    return _api.request(
      method,
      path,
      token: token,
      body: body,
      errorMessage: error,
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: onSuccess,
    );
  }

  List<VolunteerAction> _decodeList(http.Response response) =>
      ApiRequester.decodeList(response).map(fromJson).toList();

  @override
  Future<List<VolunteerAction>> open(String token) => _call(
    HttpMethod.get,
    '/volunteer-action',
    token,
    'Não foi possível carregar as ações.',
    _decodeList,
  );

  @override
  Future<VolunteerAction> get(int id, String token) => _call(
    HttpMethod.get,
    '/volunteer-action/$id',
    token,
    'Não foi possível carregar a ação.',
    _decode,
  );

  @override
  Future<List<VolunteerAction>> mine(String token) => _call(
    HttpMethod.get,
    '/volunteer-action/mine',
    token,
    'Não foi possível carregar as ações.',
    _decodeList,
  );

  @override
  Future<VolunteerAction> save(
    VolunteerActionParams params,
    String token, {
    int? id,
  }) => _call(
    id == null ? HttpMethod.post : HttpMethod.put,
    id == null ? '/volunteer-action' : '/volunteer-action/$id',
    token,
    'Não foi possível salvar a ação.',
    _decode,
    body: {
      'title': params.title.trim(),
      'date': DateInputFormatter.toIso(params.date),
      'startTime': params.startTime,
      'endTime': params.endTime,
      'volunteersNeeded': params.volunteersNeeded,
      'street': params.street.trim(),
      'number': _text(params.number),
      'city': params.city.trim(),
      'state': params.state,
      'zipCode': _text(params.zipCode),
      'description': params.description.trim(),
      'tasks': _text(params.tasks),
      'requirements': _text(params.requirements),
      'notes': _text(params.notes),
    },
  );

  @override
  Future<VolunteerAction> finish(int id, String token) => _call(
    HttpMethod.post,
    '/volunteer-action/$id/finish',
    token,
    'Não foi possível finalizar a ação.',
    _decode,
  );

  @override
  Future<VolunteerAction> apply(int id, String token) => _call(
    HttpMethod.post,
    '/volunteer-action/$id/apply',
    token,
    'Não foi possível enviar sua candidatura.',
    _decode,
  );

  @override
  Future<VolunteerAction> withdraw(int id, String token) => _call(
    HttpMethod.delete,
    '/volunteer-action/$id/apply',
    token,
    'Não foi possível cancelar sua candidatura.',
    _decode,
  );

  @override
  Future<List<VolunteerApplication>> volunteers(int id, String token) => _call(
    HttpMethod.get,
    '/volunteer-action/$id/volunteers',
    token,
    'Não foi possível carregar os voluntários.',
    (response) =>
        ApiRequester.decodeList(response).map(applicationFromJson).toList(),
  );

  @override
  Future<VolunteerApplication> accept(
    int actionId,
    int applicationId,
    String token,
  ) => _call(
    HttpMethod.post,
    '/volunteer-action/$actionId/volunteers/$applicationId/accept',
    token,
    'Não foi possível aceitar o voluntário.',
    (response) => applicationFromJson(ApiRequester.decodeObject(response)),
  );
}
