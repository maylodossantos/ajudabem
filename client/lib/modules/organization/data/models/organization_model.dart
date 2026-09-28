import '../../domain/entities/organization.dart';

abstract final class OrganizationModel {
  static Organization fromJson(Map<String, dynamic> json) {
    return Organization(
      id: (json['id'] as num?)?.toInt() ?? 0,
      corporateName: json['corporateName'] as String? ?? '',
      tradeName: json['tradeName'] as String? ?? '',
      cnpj: json['cnpj'] as String? ?? '',
      status: OrganizationStatus.fromApi(json['status'] as String?),
      activityArea: json['activityArea'] as String? ?? '',
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
      submittedAt: _date(json['submittedAt']),
      reviewedAt: _date(json['reviewedAt']),
      rejectionReason: RejectionReason.fromApi(
        json['rejectionReason'] as String?,
      ),
      rejectionNote: json['rejectionNote'] as String?,
      resubmitAvailableAt: _date(json['resubmitAvailableAt']),
      documents: [
        for (final document
            in (json['documents'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>())
          if (OrganizationDocumentType.fromApi(document['type'] as String?)
              case final type?)
            OrganizationDocument(
              type: type,
              fileName: document['fileName'] as String? ?? '',
              sizeBytes: (document['sizeBytes'] as num?)?.toInt() ?? 0,
              sentAt: _date(document['sentAt']),
            ),
      ],
    );
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
