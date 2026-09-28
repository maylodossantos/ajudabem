import 'package:flutter/material.dart';

import '../../../../core/geo/geo_point.dart';

enum AssistanceType {
  shelter('SHELTER', 'Abrigo', Color(0xFF009B7D)),
  overnight('OVERNIGHT', 'Pernoite', Color(0xFF6A4BF0)),
  reception('RECEPTION', 'Acolhimento', Color(0xFF12BFC7)),
  food('FOOD', 'Alimentação', Color(0xFF1A7FF5)),
  clothing('CLOTHING', 'Doação de roupas', Color(0xFFE8841A)),
  medical('MEDICAL', 'Atendimento médico', Color(0xFFE5484D)),
  psychological('PSYCHOLOGICAL', 'Atendimento psicológico', Color(0xFF8E44AD));

  const AssistanceType(this.apiValue, this.label, this.color);

  final String apiValue;
  final String label;
  final Color color;

  static AssistanceType? fromApi(String? value) {
    for (final type in values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }
}

enum HelpPointOrganizationType {
  ngo('NGO', 'ONGs'),
  church('CHURCH', 'Igrejas'),
  municipalShelter('MUNICIPAL_SHELTER', 'Abrigos municipais'),
  socialProject('SOCIAL_PROJECT', 'Projetos sociais'),
  volunteerInitiative('VOLUNTEER_INITIATIVE', 'Iniciativas voluntárias'),
  publicHealth('PUBLIC_HEALTH', 'Saúde pública');

  const HelpPointOrganizationType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static HelpPointOrganizationType fromApi(String? value) =>
      values.firstWhere((type) => type.apiValue == value, orElse: () => ngo);
}

class OpeningHours {
  const OpeningHours({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
  });

  final int weekday;
  final int opensAt;
  final int closesAt;

  static const apiDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  static const dayNames = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  bool get isAllDay => opensAt == closesAt;

  bool get crossesMidnight => !isAllDay && closesAt < opensAt;

  bool get coversNight => isAllDay || crossesMidnight || closesAt >= 22 * 60;

  bool isOpenAt(DateTime moment) {
    final minute = moment.hour * 60 + moment.minute;
    final yesterday = moment.weekday == DateTime.monday
        ? DateTime.sunday
        : moment.weekday - 1;

    if (isAllDay) return weekday == moment.weekday;
    if (!crossesMidnight) {
      return weekday == moment.weekday &&
          minute >= opensAt &&
          minute < closesAt;
    }
    return (weekday == moment.weekday && minute >= opensAt) ||
        (weekday == yesterday && minute < closesAt);
  }

  static String formatMinutes(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}h'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  static String toApiTime(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  static int? fromApiTime(String? value) {
    final parts = value?.split(':');
    if (parts == null || parts.length < 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    return hours * 60 + minutes;
  }

  String get timeLabel => isAllDay
      ? '24 horas'
      : '${formatMinutes(opensAt)} às ${formatMinutes(closesAt)}';
}

class HelpPoint {
  const HelpPoint({
    required this.id,
    required this.name,
    required this.organizationType,
    this.description = '',
    this.coverImage,
    this.services = const [],
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.location,
    this.phone,
    this.whatsapp,
    this.email,
    this.responsible,
    this.openingHours = const [],
    this.scheduleNote,
    this.notes,
    this.createdAt,
  });

  final int id;
  final String name;
  final HelpPointOrganizationType organizationType;
  final String description;
  final String? coverImage;
  final List<AssistanceType> services;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;

  final String zipCode;

  final GeoPoint? location;

  final String? phone;

  final String? whatsapp;
  final String? email;
  final String? responsible;
  final List<OpeningHours> openingHours;
  final String? scheduleNote;

  final String? notes;
  final DateTime? createdAt;

  String get cityLabel =>
      [city, state].where((part) => part.isNotEmpty).join(' - ');

  String get streetLabel {
    final numbered = number.isEmpty ? street : '$street, Nº $number';
    return neighborhood.isEmpty ? numbered : '$numbered - $neighborhood';
  }

  List<String> get noteLines => (notes ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  bool isOpenAt(DateTime moment) =>
      openingHours.any((hours) => hours.isOpenAt(moment));

  bool opensOn(DateTime day) =>
      openingHours.any((hours) => hours.weekday == day.weekday);

  bool get hasNightService => openingHours.any((hours) => hours.coversNight);

  bool get isAlwaysOpen =>
      openingHours.length >= 7 &&
      openingHours.every((hours) => hours.isAllDay) &&
      openingHours.map((hours) => hours.weekday).toSet().length == 7;

  List<String> get scheduleLines {
    if (isAlwaysOpen) return const ['Todos os dias: 24 horas'];

    final byDay = {for (final hours in openingHours) hours.weekday: hours};
    final lines = <String>[];
    var day = DateTime.monday;
    while (day <= DateTime.sunday) {
      final hours = byDay[day];
      if (hours == null) {
        day++;
        continue;
      }
      var last = day;
      while (last < DateTime.sunday &&
          byDay[last + 1]?.opensAt == hours.opensAt &&
          byDay[last + 1]?.closesAt == hours.closesAt) {
        last++;
      }
      final first = OpeningHours.dayNames[day - 1];
      final end = OpeningHours.dayNames[last - 1];
      final days = day == last
          ? first
          : last == day + 1
          ? '$first e $end'
          : '$first a $end';
      lines.add('$days: ${hours.timeLabel}');
      day = last + 1;
    }
    return lines;
  }
}
