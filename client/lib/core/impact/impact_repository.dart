import 'package:http/http.dart' as http;

import '../network/api_requester.dart';

class PlatformImpact {
  const PlatformImpact({
    required this.registered,
    required this.inCare,
    required this.newBeginnings,
  });

  final int registered;
  final int inCare;
  final int newBeginnings;
}

class OrganizationImpact {
  const OrganizationImpact({
    required this.peopleHelped,
    required this.volunteers,
    required this.campaignsFinished,
  });

  final int peopleHelped;
  final int volunteers;
  final int campaignsFinished;
}

class ImpactRepository {
  ImpactRepository(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static int _count(Map<String, dynamic> json, String key) =>
      (json[key] as num?)?.toInt() ?? 0;

  Future<PlatformImpact> platform(String token) {
    return _api.request(
      HttpMethod.get,
      '/impact',
      token: token,
      errorMessage: 'Não foi possível carregar o impacto.',
      useServerMessage: false,
      sessionExpiredStatuses: const {401},
      onSuccess: (response) {
        final json = ApiRequester.decodeObject(response);
        return PlatformImpact(
          registered: _count(json, 'registered'),
          inCare: _count(json, 'inCare'),
          newBeginnings: _count(json, 'newBeginnings'),
        );
      },
    );
  }

  Future<OrganizationImpact> organization(String token) {
    return _api.request(
      HttpMethod.get,
      '/impact/organization',
      token: token,
      errorMessage: 'Não foi possível carregar o impacto da ONG.',
      useServerMessage: false,
      sessionExpiredStatuses: const {401},
      onSuccess: (response) {
        final json = ApiRequester.decodeObject(response);
        return OrganizationImpact(
          peopleHelped: _count(json, 'peopleHelped'),
          volunteers: _count(json, 'volunteers'),
          campaignsFinished: _count(json, 'campaignsFinished'),
        );
      },
    );
  }
}
