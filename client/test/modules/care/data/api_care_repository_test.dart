import 'dart:convert';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/care/data/api_care_repository.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_record_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {'content-type': 'application/json; charset=utf-8'};

  Map<String, dynamic> personJson({String careStatus = 'NOMINATED'}) => {
    'id': 7,
    'fullName': 'Maria Souza',
    'age': 40,
    'gender': 'FEMALE',
    'riskLevel': 'HIGH',
    'careStatus': careStatus,
    'finishReason': null,
    'tags': [
      {'id': 1, 'name': 'Alimentação'},
      {'id': 2, 'name': 'Moradia'},
    ],
    'notes': 'Dorme na praça',
    'neighborhood': 'Centro',
    'city': 'Cascavel',
    'state': 'PR',
    'zipCode': '85800000',
    'latitude': -24.95,
    'longitude': -53.45,
    'createdAt': '2026-09-01T10:00:00',
    'careStartedAt': null,
    'careUpdatedAt': null,
    'organization': careStatus == 'NOMINATED'
        ? null
        : {'id': 3, 'tradeName': 'Amigos dos Rios'},
    'distanceKm': 2.4,
  };

  test('nominated maps people, needs and distance', () async {
    late http.Request sent;
    final repository = ApiCareRepository(
      MockClient((request) async {
        sent = request;
        return http.Response(jsonEncode([personJson()]), 200, headers: json);
      }),
    );

    final cases = await repository.nominated('jwt');

    expect(sent.url.path, '/care/nominated');
    expect(sent.headers['Authorization'], 'Bearer jwt');
    final person = cases.single;
    expect(person.fullName, 'Maria Souza');
    expect(person.urgency, Urgency.high);
    expect(person.status, CareStatus.nominated);
    expect(person.needs, ['Alimentação', 'Moradia']);
    expect(person.distanceKm, 2.4);
    expect(person.region, 'Centro');
    expect(person.hasLocation, isTrue);
  });

  test('addRecord sends the record and reads the updated case', () async {
    late Map<String, dynamic> body;
    final repository = ApiCareRepository(
      MockClient((request) async {
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'person': personJson(careStatus: 'FINISHED')
              ..['finishReason'] = 'HELPED',
            'records': [
              {
                'id': 1,
                'number': 1,
                'status': 'FINISHED',
                'occurredAt': '2026-09-02T14:30:00',
                'referral': 'CRAS Centro',
                'finishReason': 'HELPED',
              },
            ],
          }),
          200,
          headers: json,
        );
      }),
    );

    final detail = await repository.addRecord(
      7,
      CareRecordParams(
        status: CareRecordStatus.finished,
        occurredAt: DateTime(2026, 9, 2, 14, 30),
        tagIds: const [1],
        referral: ' CRAS Centro ',
        situation: '   ',
        finishReason: FinishReason.helped,
      ),
      'jwt',
    );

    expect(body['status'], 'FINISHED');
    expect(body['occurredAt'], '2026-09-02T14:30:00');
    expect(body['tagIds'], [1]);
    expect(body['referral'], 'CRAS Centro');
    expect(body['situation'], isNull);
    expect(body['finishReason'], 'HELPED');
    expect(detail.person.status, CareStatus.finished);
    expect(detail.person.finishReason, FinishReason.helped);
    expect(detail.person.organizationName, 'Amigos dos Rios');
    expect(detail.records.single.status, CareRecordStatus.finished);
    expect(detail.referrals, ['CRAS Centro']);
  });

  test('assume translates a case taken by another ONG', () async {
    final repository = ApiCareRepository(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Case already assumed', 'status': 409}),
          409,
          headers: json,
        ),
      ),
    );

    await expectLater(
      repository.assume(7, 'jwt'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Outra ONG já assumiu este atendimento.',
        ),
      ),
    );
  });
}
