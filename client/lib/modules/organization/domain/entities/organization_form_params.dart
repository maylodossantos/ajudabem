import '../../../../core/files/selected_file.dart';
import 'organization.dart';

class OrganizationFormParams {
  const OrganizationFormParams({
    required this.corporateName,
    required this.tradeName,
    required this.cnpj,
    required this.activityArea,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.website,
    required this.instagram,
    required this.documentFiles,
    required this.acceptedTerms,
    required this.acceptedDataProcessing,
    required this.declaredTruthful,
  });

  final String corporateName;
  final String tradeName;

  final String cnpj;
  final String activityArea;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;

  final String zipCode;
  final String website;
  final String instagram;

  final Map<OrganizationDocumentType, SelectedFile> documentFiles;
  final bool acceptedTerms;
  final bool acceptedDataProcessing;
  final bool declaredTruthful;
}
