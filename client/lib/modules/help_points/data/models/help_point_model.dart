import '../../../../core/geo/geo_point.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_form_params.dart';

abstract final class HelpPointModel {
  static HelpPoint fromJson(Map<String, dynamic> json) {
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();

    return HelpPoint(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      organizationType: HelpPointOrganizationType.fromApi(
        json['organizationType'] as String?,
      ),
      description: json['description'] as String? ?? '',
      coverImage: json['coverImage'] as String?,
      services: [
        for (final value in json['services'] as List<dynamic>? ?? const [])
          ?AssistanceType.fromApi(value as String?),
      ]..sort((a, b) => a.index.compareTo(b.index)),
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      location: latitude == null || longitude == null
          ? null
          : GeoPoint(latitude, longitude),
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      responsible: json['responsible'] as String?,
      openingHours: [
        for (final hours
            in (json['openingHours'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>())
          ?_hoursFromJson(hours),
      ],
      scheduleNote: json['scheduleNote'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  static OpeningHours? _hoursFromJson(Map<String, dynamic> json) {
    final day = OpeningHours.apiDays.indexOf(
      json['dayOfWeek'] as String? ?? '',
    );
    final opensAt = OpeningHours.fromApiTime(json['opensAt'] as String?);
    final closesAt = OpeningHours.fromApiTime(json['closesAt'] as String?);
    if (day < 0 || opensAt == null || closesAt == null) return null;
    return OpeningHours(weekday: day + 1, opensAt: opensAt, closesAt: closesAt);
  }

  static Map<String, dynamic> toJson(HelpPointFormParams params) {
    String? orNull(String value) => value.trim().isEmpty ? null : value.trim();

    return {
      'name': params.name.trim(),
      'description': orNull(params.description),
      'coverImage': params.coverImage,
      'organizationType': params.organizationType.apiValue,
      'services': [for (final type in params.services) type.apiValue],
      'street': params.street.trim(),
      'number': orNull(params.number),
      'neighborhood': orNull(params.neighborhood),
      'city': params.city.trim(),
      'state': params.state,
      'zipCode': orNull(params.zipCode),
      'phone': orNull(params.phone),
      'whatsapp': orNull(params.whatsapp),
      'email': orNull(params.email),
      'responsible': orNull(params.responsible),
      'openingHours': [
        for (final hours in params.openingHours)
          {
            'dayOfWeek': OpeningHours.apiDays[hours.weekday - 1],
            'opensAt': OpeningHours.toApiTime(hours.opensAt),
            'closesAt': OpeningHours.toApiTime(hours.closesAt),
          },
      ],
      'scheduleNote': orNull(params.scheduleNote),
      'notes': orNull(params.notes),
    };
  }
}
