import 'dart:typed_data';

import '../../domain/entities/organization.dart';
import '../../domain/entities/organization_form_params.dart';

abstract interface class OrganizationDatasource {
  Future<Organization?> getMine(String token);

  Future<Organization> submit(OrganizationFormParams params, String token);

  Future<List<Organization>> list(
    String token, {
    OrganizationStatus? status,
    String? search,
  });

  Future<Organization> approve(int id, String token);

  Future<Organization> reject(
    int id,
    RejectionReason reason,
    String? note,
    String token,
  );

  Future<Uint8List> downloadDocument(
    int organizationId,
    OrganizationDocumentType type,
    String token,
  );
}
