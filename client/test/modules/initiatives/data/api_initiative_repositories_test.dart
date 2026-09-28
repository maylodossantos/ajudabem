import 'dart:convert';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/initiatives/data/api_initiative_repositories.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/volunteer_action.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {'content-type': 'application/json; charset=utf-8'};

  test('campaigns are read publicly and saved with a clean body', () async {
    final requests = <http.Request>[];
    final repository = ApiCampaignRepository(
      MockClient((request) async {
        requests.add(request);
        final campaign = {
          'id': 3,
          'title': 'Inverno Solidário',
          'description': 'Agasalhos',
          'category': 'CLOTHING',
          'goalAmount': 1500.5,
          'deadline': '2026-10-01',
          'status': 'ACTIVE',
          'organization': {'id': 1, 'tradeName': 'Amigos dos Rios'},
        };
        return http.Response(
          jsonEncode(request.method == 'GET' ? [campaign] : campaign),
          200,
          headers: json,
        );
      }),
    );

    final active = await repository.active();
    expect(requests.last.headers['Authorization'], isNull);
    expect(active.single.category, CampaignCategory.clothing);
    expect(active.single.organizationName, 'Amigos dos Rios');
    expect(active.single.goalAmount, 1500.5);
    expect(active.single.deadline, DateTime(2026, 10));

    await repository.save(
      CampaignParams(
        title: ' Inverno ',
        description: 'Agasalhos',
        category: CampaignCategory.clothing,
        subtitle: '  ',
        goalAmount: 1500.5,
        deadline: DateTime(2026, 10),
      ),
      'jwt',
      id: 3,
    );
    final body = jsonDecode(requests.last.body) as Map<String, dynamic>;
    expect(requests.last.method, 'PUT');
    expect(requests.last.url.path, '/campaign/3');
    expect(body['title'], 'Inverno');
    expect(body['subtitle'], isNull);
    expect(body['deadline'], '2026-10-01');
    expect(body['category'], 'CLOTHING');
  });

  test('actions carry the application and the contact of the ONG', () async {
    final repository = ApiVolunteerActionRepository(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'id': 8,
            'title': 'Distribuição',
            'date': '2026-03-21',
            'startTime': '18:00:00',
            'endTime': '21:00:00',
            'volunteersNeeded': 6,
            'acceptedCount': 3,
            'status': 'ACTIVE',
            'street': 'Praça Wilson Joffre',
            'city': 'Cascavel',
            'myApplication': 'ACCEPTED',
            'contact': {'phone': '45999990000', 'email': 'ong@example.com'},
            'organization': {'id': 1, 'tradeName': 'Mãos que Ajudam'},
          }),
          200,
          headers: json,
        ),
      ),
    );

    final action = await repository.get(8, 'jwt');

    expect(action.startTime, '18:00');
    expect(action.scheduleLabel, '18:00 – 21:00');
    expect(action.dateLabel, 'Sábado, 21 de março.');
    expect(action.vacanciesLabel, '3 de 6 vagas');
    expect(action.myApplication, ApplicationStatus.accepted);
    expect(action.contactPhone, '45999990000');
    expect(action.placeLabel, 'Praça Wilson Joffre – Cascavel');
  });

  test('a full action explains why the application failed', () async {
    final repository = ApiVolunteerActionRepository(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'No vacancies left', 'status': 409}),
          409,
          headers: json,
        ),
      ),
    );

    await expectLater(
      repository.apply(8, 'jwt'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Não há mais vagas nesta ação.',
        ),
      ),
    );
  });
}
