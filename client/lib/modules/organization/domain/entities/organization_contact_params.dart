class OrganizationContactParams {
  const OrganizationContactParams({
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.website,
    required this.instagram,
  });

  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String website;
  final String instagram;
}
