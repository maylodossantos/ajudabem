import 'package:http/http.dart' as http;

import '../../../core/network/api_requester.dart';
import '../domain/entities/care_case.dart';
import '../domain/entities/care_record_params.dart';
import '../domain/repositories/care_repository.dart';

class ApiCareRepository implements CareRepository {
  ApiCareRepository(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  static const _serverMessages = {
    'Case already assumed': 'Outra ONG já assumiu este atendimento.',
    'Case already finished': 'Este atendimento já foi finalizado.',
    'Only the organization in charge can do this':
        'Só a ONG responsável pode atualizar este atendimento.',
  };

  @override
  Future<List<CareCase>> nominated(String token) =>
      _list('/care/nominated', token, 'Não foi possível carregar os casos.');

  @override
  Future<List<CareCase>> myCases(String token) =>
      _list('/care/cases', token, 'Não foi possível carregar os atendimentos.');

  @override
  Future<List<CareCase>> map(String token) =>
      _list('/care/map', token, 'Não foi possível carregar o mapa.');

  @override
  Future<CareCaseDetail> get(int personId, String token) {
    return _api.request(
      HttpMethod.get,
      '/care/$personId',
      token: token,
      errorMessage: 'Não foi possível carregar o caso.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          detailFromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<CareCase> assume(int personId, String token) {
    return _api.request(
      HttpMethod.post,
      '/care/$personId/assume',
      token: token,
      errorMessage: 'Não foi possível assumir o atendimento.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          caseFromJson(ApiRequester.decodeObject(response)),
    );
  }

  @override
  Future<CareCaseDetail> addRecord(
    int personId,
    CareRecordParams params,
    String token,
  ) {
    String? text(String value) => value.trim().isEmpty ? null : value.trim();

    return _api.request(
      HttpMethod.post,
      '/care/$personId/records',
      token: token,
      body: {
        'status': params.status.apiValue,
        'occurredAt': params.occurredAt.toIso8601String().split('.').first,
        'tagIds': ?params.tagIds,
        'situation': text(params.situation),
        'actionTaken': text(params.actionTaken),
        'referral': text(params.referral),
        'nextStep': text(params.nextStep),
        'summary': text(params.summary),
        'note': text(params.note),
        'finishReason': params.finishReason?.apiValue,
      },
      errorMessage: 'Não foi possível salvar o atendimento.',
      serverMessages: _serverMessages,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          detailFromJson(ApiRequester.decodeObject(response)),
    );
  }

  Future<List<CareCase>> _list(String path, String token, String error) {
    return _api.request(
      HttpMethod.get,
      path,
      token: token,
      errorMessage: error,
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) =>
          ApiRequester.decodeList(response).map(caseFromJson).toList(),
    );
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static CareCase caseFromJson(Map<String, dynamic> json) {
    final organization = json['organization'];
    return CareCase(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['fullName'] as String? ?? '',
      urgency: Urgency.fromApi(json['riskLevel'] as String?),
      status: CareStatus.fromApi(json['careStatus'] as String?),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      finishReason: FinishReason.fromApi(json['finishReason'] as String?),
      needs: [
        for (final tag
            in (json['tags'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>())
          tag['name'] as String? ?? '',
      ],
      notes: json['notes'] as String? ?? '',
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: _date(json['createdAt']),
      careStartedAt: _date(json['careStartedAt']),
      careUpdatedAt: _date(json['careUpdatedAt']),
      organizationName: organization is Map<String, dynamic>
          ? organization['tradeName'] as String?
          : null,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  static CareCaseDetail detailFromJson(Map<String, dynamic> json) {
    return CareCaseDetail(
      person: caseFromJson(json['person'] as Map<String, dynamic>? ?? const {}),
      records: [
        for (final record
            in (json['records'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>())
          CareRecord(
            id: (record['id'] as num?)?.toInt() ?? 0,
            number: (record['number'] as num?)?.toInt() ?? 0,
            status: CareRecordStatus.fromApi(record['status'] as String?),
            occurredAt: _date(record['occurredAt']) ?? DateTime(0),
            situation: record['situation'] as String?,
            actionTaken: record['actionTaken'] as String?,
            referral: record['referral'] as String?,
            nextStep: record['nextStep'] as String?,
            summary: record['summary'] as String?,
            note: record['note'] as String?,
            finishReason: FinishReason.fromApi(
              record['finishReason'] as String?,
            ),
          ),
      ],
    );
  }
}
