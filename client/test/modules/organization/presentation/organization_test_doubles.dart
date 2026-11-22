import 'dart:typed_data';

import 'package:ajuda_bem/core/files/selected_file.dart';
import 'package:ajuda_bem/core/services/document_picker_service.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization_contact_params.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization_form_params.dart';
import 'package:ajuda_bem/modules/organization/domain/repositories/organization_repository.dart';

Organization organizationWith({
  OrganizationStatus status = OrganizationStatus.pending,
  List<OrganizationDocument> documents = const [],
}) {
  return Organization(
    id: 5,
    corporateName: 'Associação Amigos dos Rios',
    tradeName: 'Amigos dos Rios',
    cnpj: '44555666000181',
    status: status,
    activityArea: 'Meio Ambiente',
    street: 'Rua das Flores',
    number: '123',
    neighborhood: 'Centro',
    city: 'Cascavel',
    state: 'PR',
    zipCode: '85800000',
    instagram: '@rios',
    documents: documents,
  );
}

class FakeOrganizationRepository implements OrganizationRepository {
  FakeOrganizationRepository({this.error, this.mine});

  final Object? error;
  final Organization? mine;
  OrganizationFormParams? submitted;
  OrganizationContactParams? contactParams;
  int? approvedId;
  (int, RejectionReason, String?)? rejected;

  Future<Organization> _answer(Organization organization) async {
    if (error != null) throw error!;
    return organization;
  }

  @override
  Future<Organization?> getMine(String token) async => mine;

  @override
  Future<Organization> submit(OrganizationFormParams params, String token) {
    submitted = params;
    return _answer(organizationWith());
  }

  @override
  Future<Organization> updateContact(
    OrganizationContactParams params,
    String token,
  ) {
    contactParams = params;
    return _answer(organizationWith(status: OrganizationStatus.approved));
  }

  @override
  Future<List<Organization>> list(
    String token, {
    OrganizationStatus? status,
    String? search,
  }) async => [organizationWith()];

  @override
  Future<Uint8List> downloadDocument(
    int organizationId,
    OrganizationDocumentType type,
    String token,
  ) async => Uint8List.fromList('%PDF-1.4'.codeUnits);

  @override
  Future<Organization> approve(int id, String token) {
    approvedId = id;
    return _answer(organizationWith(status: OrganizationStatus.approved));
  }

  @override
  Future<Organization> reject(
    int id,
    RejectionReason reason,
    String? note,
    String token,
  ) {
    rejected = (id, reason, note);
    return _answer(organizationWith(status: OrganizationStatus.rejected));
  }
}

class FakeDocumentPicker implements DocumentPickerService {
  SelectedFile? next;

  @override
  Future<SelectedFile?> pickPdf() async => next;
}

SelectedFile pdfFile(String name, {int size = 16}) =>
    SelectedFile(name: name, bytes: Uint8List(size));
