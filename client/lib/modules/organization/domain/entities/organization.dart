enum OrganizationStatus {
  pending('PENDING', 'Pendente'),
  approved('APPROVED', 'Aprovada'),
  rejected('REJECTED', 'Reprovada');

  const OrganizationStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static OrganizationStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => pending,
  );
}

enum OrganizationDocumentType {
  cnpjProof('CNPJ_PROOF', 'Comprovante de CNPJ'),
  bylaws('BYLAWS', 'Estatuto Social'),
  boardElectionMinutes(
    'BOARD_ELECTION_MINUTES',
    'Ata da última eleição da diretoria',
  ),
  responsibleId('RESPONSIBLE_ID', 'Documento do responsável');

  const OrganizationDocumentType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static OrganizationDocumentType? fromApi(String? value) {
    for (final type in values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }
}

enum RejectionReason {
  illegibleDocuments('ILLEGIBLE_DOCUMENTS', 'Documentos ilegíveis'),
  invalidDocuments('INVALID_DOCUMENTS', 'Documentos inválidos ou vencidos'),
  dataMismatch('DATA_MISMATCH', 'Dados divergentes dos documentos'),
  irregularCnpj('IRREGULAR_CNPJ', 'CNPJ inativo ou irregular'),
  other('OTHER', 'Outro motivo');

  const RejectionReason(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static RejectionReason? fromApi(String? value) {
    for (final reason in values) {
      if (reason.apiValue == value) return reason;
    }
    return null;
  }
}

abstract final class ActivityAreas {
  static const all = [
    'Assistência Social',
    'Reinserção Social',
    'Saúde',
    'Educação',
    'Moradia',
    'Alimentação',
    'Meio Ambiente',
    'Direitos Humanos',
    'Outra',
  ];
}

class OrganizationDocument {
  const OrganizationDocument({
    required this.type,
    required this.fileName,
    this.sizeBytes = 0,
    this.sentAt,
  });

  final OrganizationDocumentType type;
  final String fileName;
  final int sizeBytes;
  final DateTime? sentAt;
}

class Organization {
  const Organization({
    required this.id,
    required this.corporateName,
    required this.tradeName,
    required this.cnpj,
    required this.status,
    this.activityArea = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.website,
    this.instagram,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.rejectionNote,
    this.resubmitAvailableAt,
    this.documents = const [],
  });

  final int id;
  final String corporateName;
  final String tradeName;

  final String cnpj;
  final OrganizationStatus status;
  final String activityArea;
  final String street;
  final String number;
  final String neighborhood;
  final String city;

  final String state;

  final String zipCode;
  final String? website;
  final String? instagram;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final RejectionReason? rejectionReason;
  final String? rejectionNote;
  final DateTime? resubmitAvailableAt;
  final List<OrganizationDocument> documents;

  OrganizationDocument? documentOf(OrganizationDocumentType type) {
    for (final document in documents) {
      if (document.type == type) return document;
    }
    return null;
  }

  bool canResubmitAt(DateTime now) {
    final availableAt = resubmitAvailableAt;
    return status == OrganizationStatus.rejected &&
        (availableAt == null || !now.isBefore(availableAt));
  }

  int daysUntilResubmit(DateTime now) {
    final availableAt = resubmitAvailableAt;
    if (availableAt == null || !now.isBefore(availableAt)) return 0;
    return (availableAt.difference(now).inHours / 24).ceil();
  }
}
