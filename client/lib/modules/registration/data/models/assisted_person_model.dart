import '../../domain/entities/assisted_person.dart';

class AssistedPersonModel {
  const AssistedPersonModel({
    required this.id,
    required this.fullName,
    required this.riskLevel,
    required this.age,
    required this.gender,
    required this.tags,
    required this.notes,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory AssistedPersonModel.fromJson(Map<String, dynamic> json) {
    return AssistedPersonModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String? ?? '',
      riskLevel: json['riskLevel'] as String? ?? 'MEDIUM',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? 'OTHER',
      tags: (json['tags'] as List<dynamic>? ?? []).whereType<String>().toList(),
      notes: json['notes'] as String? ?? '',
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

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

  AssistedPerson toEntity() {
    return AssistedPerson(
      id: id,
      fullName: fullName,
      riskLevel: riskLevel,
      age: age,
      gender: gender,
      tags: tags,
      notes: notes,
      street: street,
      number: number,
      neighborhood: neighborhood,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );
  }
}
