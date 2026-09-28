import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import 'campaign.dart';

enum ApplicationStatus {
  pending('PENDING'),
  accepted('ACCEPTED');

  const ApplicationStatus(this.apiValue);

  final String apiValue;

  static ApplicationStatus? fromApi(String? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

class VolunteerAction {
  const VolunteerAction({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.volunteersNeeded,
    required this.status,
    this.acceptedCount = 0,
    this.pendingCount = 0,
    this.street = '',
    this.number = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.description = '',
    this.tasks = '',
    this.requirements = '',
    this.notes = '',
    this.organizationName = '',
    this.myApplication,
    this.contactPhone,
    this.contactEmail,
  });

  final int id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int volunteersNeeded;
  final int acceptedCount;
  final int pendingCount;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String description;
  final String tasks;
  final String requirements;
  final String notes;
  final InitiativeStatus status;
  final String organizationName;
  final ApplicationStatus? myApplication;
  final String? contactPhone;
  final String? contactEmail;

  bool get isActive => status == InitiativeStatus.active;

  bool get isFull => acceptedCount >= volunteersNeeded;

  String get dateLabel => '${DateInputFormatter.longDate(date)}.';

  String get scheduleLabel => '$startTime – $endTime';

  String get vacanciesLabel => '$acceptedCount de $volunteersNeeded vagas';

  String get volunteersLabel => volunteersNeeded == 1
      ? '1 Voluntário necessário'
      : '$volunteersNeeded Voluntários necessários';

  String get placeLabel => [
    number.isEmpty ? street : '$street, $number',
    city,
  ].where((part) => part.isNotEmpty).join(' – ');

  String get addressLabel => [
    placeLabel,
    state,
    CepInputFormatter.display(zipCode),
  ].where((part) => part.isNotEmpty).join(' - ');

  VolunteerAction withApplication(ApplicationStatus? application) =>
      VolunteerAction(
        id: id,
        title: title,
        date: date,
        startTime: startTime,
        endTime: endTime,
        volunteersNeeded: volunteersNeeded,
        status: status,
        acceptedCount: acceptedCount,
        pendingCount: pendingCount,
        street: street,
        number: number,
        city: city,
        state: state,
        zipCode: zipCode,
        description: description,
        tasks: tasks,
        requirements: requirements,
        notes: notes,
        organizationName: organizationName,
        myApplication: application,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
      );
}

class VolunteerActionParams {
  const VolunteerActionParams({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.volunteersNeeded,
    required this.street,
    required this.city,
    required this.state,
    required this.description,
    this.number = '',
    this.zipCode = '',
    this.tasks = '',
    this.requirements = '',
    this.notes = '',
  });

  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int volunteersNeeded;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String description;
  final String tasks;
  final String requirements;
  final String notes;
}

class VolunteerApplication {
  const VolunteerApplication({
    required this.id,
    required this.name,
    required this.status,
    this.profileImage,
    this.phone,
  });

  final int id;
  final String name;
  final String? profileImage;
  final String? phone;
  final ApplicationStatus status;

  bool get isAccepted => status == ApplicationStatus.accepted;
}
