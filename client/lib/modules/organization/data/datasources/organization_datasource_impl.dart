import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_requester.dart';
import '../../../../core/network/server_messages.dart';
import '../../domain/entities/organization.dart';
import '../../domain/entities/organization_form_params.dart';
import '../models/organization_model.dart';
import 'organization_datasource.dart';

class OrganizationDatasourceImpl implements OrganizationDatasource {
  OrganizationDatasourceImpl(http.Client client) : _api = ApiRequester(client);

  final ApiRequester _api;

  static const _sessionExpiredStatuses = {401};

  static Organization _decode(http.Response response) =>
      OrganizationModel.fromJson(ApiRequester.decodeObject(response));

  @override
  Future<Organization?> getMine(String token) {
    return _api.request<Organization?>(
      HttpMethod.get,
      '/organization/me',
      token: token,
      errorMessage: 'Não foi possível carregar a validação da sua ONG.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      statusResults: {404: () => null},
      onSuccess: _decode,
    );
  }

  @override
  Future<Organization> submit(OrganizationFormParams params, String token) {
    return _api.request(
      HttpMethod.post,
      '/organization/me',
      token: token,
      body: {
        'corporateName': params.corporateName,
        'tradeName': params.tradeName,
        'cnpj': params.cnpj,
        'activityArea': params.activityArea,
        'street': params.street,
        'number': params.number,
        'neighborhood': params.neighborhood,
        'city': params.city,
        'state': params.state,
        'zipCode': params.zipCode,
        'website': params.website,
        'instagram': params.instagram,
        'acceptedTerms': params.acceptedTerms,
        'acceptedDataProcessing': params.acceptedDataProcessing,
        'declaredTruthful': params.declaredTruthful,
      },
      files: {
        for (final MapEntry(key: type, value: file)
            in params.documentFiles.entries)
          type.apiValue: ApiFile(
            fileName: file.name,
            bytes: file.bytes,
            contentType: 'application/pdf',
          ),
      },
      errorMessage: 'Não foi possível enviar a validação da ONG.',
      statusMessages: const {
        413: 'Os documentos precisam ter no máximo 10 MB cada.',
      },
      serverMessages: ServerMessages.organization,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  @override
  Future<List<Organization>> list(
    String token, {
    OrganizationStatus? status,
    String? search,
  }) {
    final query = {
      'status': ?status?.apiValue,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final path = Uri(
      path: '/organization',
      queryParameters: query.isEmpty ? null : query,
    ).toString();

    return _api.request(
      HttpMethod.get,
      path,
      token: token,
      errorMessage: 'Não foi possível carregar as validações.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) => ApiRequester.decodeList(
        response,
      ).map(OrganizationModel.fromJson).toList(),
    );
  }

  @override
  Future<Organization> approve(int id, String token) {
    return _api.request(
      HttpMethod.post,
      '/organization/$id/approve',
      token: token,
      errorMessage: 'Não foi possível aprovar a ONG.',
      serverMessages: ServerMessages.organization,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  @override
  Future<Organization> reject(
    int id,
    RejectionReason reason,
    String? note,
    String token,
  ) {
    return _api.request(
      HttpMethod.post,
      '/organization/$id/reject',
      token: token,
      body: {
        'reason': reason.apiValue,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
      errorMessage: 'Não foi possível reprovar a ONG.',
      serverMessages: ServerMessages.organization,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: _decode,
    );
  }

  @override
  Future<Uint8List> downloadDocument(
    int organizationId,
    OrganizationDocumentType type,
    String token,
  ) {
    return _api.request(
      HttpMethod.get,
      '/organization/$organizationId/documents/${type.apiValue}',
      token: token,
      errorMessage: 'Não foi possível abrir o documento.',
      useServerMessage: false,
      sessionExpiredStatuses: _sessionExpiredStatuses,
      onSuccess: (response) => response.bodyBytes,
    );
  }
}
