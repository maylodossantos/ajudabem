class AssistedPerson {
  const AssistedPerson({
    required this.id,
    required this.fullName,
    this.riskLevel,
    this.careStatus = 'NOMINATED',
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

  final String? riskLevel;
  final String careStatus;
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

  String get statusLabel => switch (careStatus) {
    'IN_CARE' => 'Atendimento iniciado',
    'FINISHED' => 'Atendimento finalizado',
    _ when riskLevel == null => 'Em triagem',
    _ => 'Informações recebidas.',
  };
}
