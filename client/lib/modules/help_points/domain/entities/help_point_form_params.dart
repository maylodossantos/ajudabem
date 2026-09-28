import 'help_point.dart';

class HelpPointFormParams {
  const HelpPointFormParams({
    required this.name,
    required this.description,
    required this.coverImage,
    required this.organizationType,
    required this.services,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.responsible,
    required this.openingHours,
    required this.scheduleNote,
    required this.notes,
  });

  final String name;
  final String description;
  final String? coverImage;
  final HelpPointOrganizationType organizationType;
  final Set<AssistanceType> services;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;

  final String zipCode;
  final String phone;
  final String whatsapp;
  final String email;
  final String responsible;
  final List<OpeningHours> openingHours;
  final String scheduleNote;
  final String notes;
}
