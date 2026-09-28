import 'dart:convert';

import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/modules/help_points/data/datasources/help_point_datasource_impl.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point_form_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {'content-type': 'application/json; charset=utf-8'};

  test('lists the public help points without a token', () async {
    late http.Request captured;
    final datasource = HelpPointDatasourceImpl(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode([
            {
              'id': 7,
              'name': 'CAPS AD III',
              'organizationType': 'PUBLIC_HEALTH',
              'services': ['RECEPTION', 'PSYCHOLOGICAL', 'SOMETHING_NEW'],
              'street': 'Rua Poente do Sol',
              'number': '788',
              'city': 'Cascavel',
              'state': 'PR',
              'latitude': -24.92,
              'longitude': -53.43,
              'phone': '4533246530',
              'openingHours': [
                {
                  'dayOfWeek': 'MONDAY',
                  'opensAt': '00:00:00',
                  'closesAt': '00:00:00',
                },
                {
                  'dayOfWeek': 'FRIDAY',
                  'opensAt': '18:00:00',
                  'closesAt': '07:00:00',
                },
              ],
              'createdAt': '2026-09-27T10:00:00',
            },
          ]),
          200,
          headers: json,
        );
      }),
    );

    final points = await datasource.getAll();

    expect(captured.url, Uri.parse('${ApiConfig.baseUrl}/help-point'));
    expect(captured.headers.containsKey('Authorization'), isFalse);
    final point = points.single;
    expect(point.organizationType, HelpPointOrganizationType.publicHealth);
    expect(point.services, [
      AssistanceType.reception,
      AssistanceType.psychological,
    ], reason: 'unknown values are skipped, the rest in a stable order');
    expect(point.location!.latitude, -24.92);
    expect(point.openingHours.first.isAllDay, isTrue);
    expect(point.openingHours.last.weekday, DateTime.friday);
    expect(point.openingHours.last.closesAt, 7 * 60);
    expect(point.streetLabel, 'Rua Poente do Sol, Nº 788');
  });

  test('creates with the admin token and the API formats', () async {
    late http.Request captured;
    final datasource = HelpPointDatasourceImpl(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'id': 1, 'name': 'Albergue', 'organizationType': 'NGO'}),
          200,
          headers: json,
        );
      }),
    );

    await datasource.create(
      const HelpPointFormParams(
        name: ' Albergue ',
        description: '',
        coverImage: null,
        organizationType: HelpPointOrganizationType.municipalShelter,
        services: {AssistanceType.shelter},
        street: 'R. Rio Borá',
        number: '1916',
        neighborhood: '',
        city: 'Cascavel',
        state: 'PR',
        zipCode: '85814508',
        phone: '1139427810',
        whatsapp: '',
        email: '',
        responsible: '',
        openingHours: [
          OpeningHours(
            weekday: DateTime.sunday,
            opensAt: 18 * 60,
            closesAt: 8 * 60,
          ),
        ],
        scheduleNote: '',
        notes: 'Entrada até 21h',
      ),
      'jwt',
    );

    expect(captured.method, 'POST');
    expect(captured.headers['Authorization'], 'Bearer jwt');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['name'], 'Albergue');
    expect(body['organizationType'], 'MUNICIPAL_SHELTER');
    expect(body['services'], ['SHELTER']);
    expect(body['neighborhood'], isNull, reason: 'blank fields go as null');
    expect(body['openingHours'], [
      {'dayOfWeek': 'SUNDAY', 'opensAt': '18:00', 'closesAt': '08:00'},
    ]);
  });
}
