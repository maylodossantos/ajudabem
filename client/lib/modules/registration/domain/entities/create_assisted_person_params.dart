class CreateAssistedPersonParams {
  const CreateAssistedPersonParams({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.tagIds,
    required this.notes,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  final String fullName;
  final int age;
  final String gender;
  final List<int> tagIds;
  final String notes;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String country;
}
