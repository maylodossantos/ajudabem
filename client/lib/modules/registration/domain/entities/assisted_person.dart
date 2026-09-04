class AssistedPerson {
  const AssistedPerson({
    required this.id,
    required this.fullName,
    this.riskLevel = 'MEDIUM',
    this.age = 0,
    this.gender = 'OTHER',
    this.tags = const [],
    this.notes = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
  });

  final int id;
  final String fullName;
  final String riskLevel;
  final int age;
  final String gender;
  final List<String> tags;
  final String notes;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String country;
}
