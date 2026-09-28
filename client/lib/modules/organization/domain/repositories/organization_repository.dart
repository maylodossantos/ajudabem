import 'dart:typed_data';

import '../entities/organization.dart';
import '../entities/organization_form_params.dart';

abstract interface class OrganizationRepository {
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
