import 'dart:typed_data';

import '../../domain/entities/organization.dart';
import '../../domain/entities/organization_form_params.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_datasource.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  const OrganizationRepositoryImpl(this._datasource);

  final OrganizationDatasource _datasource;

  @override
  Future<Organization?> getMine(String token) => _datasource.getMine(token);

  @override
  Future<Organization> submit(OrganizationFormParams params, String token) =>
      _datasource.submit(params, token);

  @override
  Future<List<Organization>> list(
    String token, {
    OrganizationStatus? status,
    String? search,
  }) => _datasource.list(token, status: status, search: search);

  @override
  Future<Organization> approve(int id, String token) =>
      _datasource.approve(id, token);

  @override
  Future<Organization> reject(
    int id,
    RejectionReason reason,
    String? note,
    String token,
  ) => _datasource.reject(id, reason, note, token);

  @override
  Future<Uint8List> downloadDocument(
    int organizationId,
    OrganizationDocumentType type,
    String token,
  ) => _datasource.downloadDocument(organizationId, type, token);
}
