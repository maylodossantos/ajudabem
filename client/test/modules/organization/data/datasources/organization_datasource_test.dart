import 'dart:convert';
import 'dart:typed_data';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/files/selected_file.dart';
import 'package:ajuda_bem/core/network/api_config.dart';
import 'package:ajuda_bem/modules/organization/data/datasources/organization_datasource_impl.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization_form_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {'content-type': 'application/json; charset=utf-8'};

  Map<String, dynamic> organizationJson({String status = 'PENDING'}) => {
    'id': 5,
    'corporateName': 'Associação Amigos dos Rios',
    'tradeName': 'Amigos dos Rios',
    'cnpj': '44555666000181',
    'activityArea': 'Meio Ambiente',
    'city': 'Cascavel',
    'state': 'PR',
    'zipCode': '85800000',
    'status': status,
    'submittedAt': '2026-06-15T10:30:00',
    'rejectionReason': status == 'REJECTED' ? 'ILLEGIBLE_DOCUMENTS' : null,
    'resubmitAvailableAt': status == 'REJECTED' ? '2026-06-22T10:30:00' : null,
    'documents': [
      {
        'type': 'CNPJ_PROOF',
        'fileName': 'cartao-cnpj.pdf',
        'sizeBytes': 2048,
        'sentAt': '2026-06-15T10:30:00',
      },
    ],
  };

  test('getMine maps the request and treats 404 as "never asked"', () async {
    final found = OrganizationDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode(organizationJson(status: 'REJECTED')),
          200,
          headers: json,
        ),
      ),
    );
    final organization = await found.getMine('jwt');

    expect(organization!.tradeName, 'Amigos dos Rios');
    expect(organization.status, OrganizationStatus.rejected);
    expect(organization.rejectionReason, RejectionReason.illegibleDocuments);
    expect(organization.resubmitAvailableAt, DateTime(2026, 6, 22, 10, 30));
    expect(
      organization.documentOf(OrganizationDocumentType.cnpjProof)?.fileName,
      'cartao-cnpj.pdf',
    );

    final missing = OrganizationDatasourceImpl(
      MockClient((_) async => http.Response('', 404)),
    );
    expect(await missing.getMine('jwt'), isNull);
  });

  test('submit sends the form and each PDF in one multipart request', () async {
    late http.Request captured;
    final datasource = OrganizationDatasourceImpl(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(organizationJson()),
          200,
          headers: json,
        );
      }),
    );

    await datasource.submit(
      OrganizationFormParams(
        corporateName: 'Associação Amigos dos Rios',
        tradeName: 'Amigos dos Rios',
        cnpj: '44555666000181',
        activityArea: 'Meio Ambiente',
        street: 'Rua das Flores',
        number: '123',
        neighborhood: 'Centro',
        city: 'Cascavel',
        state: 'PR',
        zipCode: '85800000',
        website: '',
        instagram: '@rios',
        documentFiles: {
          OrganizationDocumentType.cnpjProof: SelectedFile(
            name: 'cartao.pdf',
            bytes: Uint8List.fromList('%PDF-1.4 cnpj'.codeUnits),
          ),
          OrganizationDocumentType.bylaws: SelectedFile(
            name: 'estatuto.pdf',
            bytes: Uint8List.fromList('%PDF-1.4 estatuto'.codeUnits),
          ),
        },
        acceptedTerms: true,
        acceptedDataProcessing: true,
        declaredTruthful: true,
      ),
      'jwt',
    );

    expect(captured.method, 'POST');
    expect(captured.url, Uri.parse('${ApiConfig.baseUrl}/organization/me'));
    expect(captured.headers['Authorization'], 'Bearer jwt');
    expect(captured.headers['content-type'], startsWith('multipart/form-data'));

    final body = utf8.decode(captured.bodyBytes);
    expect(body, contains('name="data"'));
    expect(body, contains('"cnpj":"44555666000181"'));
    expect(body, contains('"acceptedDataProcessing":true'));
    expect(body, contains('name="CNPJ_PROOF"; filename="cartao.pdf"'));
    expect(body, contains('name="BYLAWS"; filename="estatuto.pdf"'));
    expect(body, contains('%PDF-1.4 estatuto'));
    expect(body, isNot(contains('ibb.co')), reason: 'no public links');
  });

  test('downloadDocument fetches the PDF with the session token', () async {
    late http.Request captured;
    final datasource = OrganizationDatasourceImpl(
      MockClient((request) async {
        captured = request;
        return http.Response.bytes(
          '%PDF-1.4'.codeUnits,
          200,
          headers: {'content-type': 'application/pdf'},
        );
      }),
    );

    final bytes = await datasource.downloadDocument(
      5,
      OrganizationDocumentType.bylaws,
      'jwt',
    );

    expect(
      captured.url,
      Uri.parse('${ApiConfig.baseUrl}/organization/5/documents/BYLAWS'),
    );
    expect(captured.headers['Authorization'], 'Bearer jwt');
    expect(String.fromCharCodes(bytes), '%PDF-1.4');
  });

  test('submit shows the waiting-period conflict in Portuguese', () {
    final datasource = OrganizationDatasourceImpl(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message':
                'Organization can only be resubmitted 7 days after the rejection',
          }),
          409,
          headers: json,
        ),
      ),
    );

    expect(
      () => datasource.submit(
        const OrganizationFormParams(
          corporateName: 'x',
          tradeName: 'x',
          cnpj: '44555666000181',
          activityArea: 'Outra',
          street: 'x',
          number: '1',
          neighborhood: '',
          city: 'x',
          state: 'PR',
          zipCode: '85800000',
          website: '',
          instagram: '',
          documentFiles: {},
          acceptedTerms: true,
          acceptedDataProcessing: true,
          declaredTruthful: true,
        ),
        'jwt',
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          contains('Aguarde 7 dias'),
        ),
      ),
    );
  });

  test('list sends the status filter and the search as query params', () async {
    late http.Request captured;
    final datasource = OrganizationDatasourceImpl(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode([organizationJson()]),
          200,
          headers: json,
        );
      }),
    );

    final result = await datasource.list(
      'jwt',
      status: OrganizationStatus.pending,
      search: ' rios ',
    );

    expect(captured.url.path, endsWith('/organization'));
    expect(captured.url.queryParameters, {
      'status': 'PENDING',
      'search': 'rios',
    });
    expect(result.single.cnpj, '44555666000181');
  });

  test('reject posts the reason and the note', () async {
    late http.Request captured;
    final datasource = OrganizationDatasourceImpl(
      MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(organizationJson(status: 'REJECTED')),
          200,
          headers: json,
        );
      }),
    );

    final result = await datasource.reject(
      5,
      RejectionReason.illegibleDocuments,
      '  Estatuto ilegível ',
      'jwt',
    );

    expect(
      captured.url,
      Uri.parse('${ApiConfig.baseUrl}/organization/5/reject'),
    );
    expect(jsonDecode(captured.body), {
      'reason': 'ILLEGIBLE_DOCUMENTS',
      'note': 'Estatuto ilegível',
    });
    expect(result.status, OrganizationStatus.rejected);
  });
}
