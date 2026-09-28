import 'package:flutter/material.dart';

import '../../../../core/formatters/cep_input_formatter.dart';

enum Urgency {
  high('HIGH', 'Alta', Color(0xFFE5484D)),
  medium('MEDIUM', 'Média', Color(0xFFF08A24)),
  low('LOW', 'Baixa', Color(0xFF34C759)),
  pending(null, 'Em triagem', Color(0xFFBDBDBD));

  const Urgency(this.apiValue, this.label, this.color);

  final String? apiValue;
  final String label;
  final Color color;

  static Urgency fromApi(String? value) => values.firstWhere(
    (urgency) => urgency.apiValue == value,
    orElse: () => pending,
  );
}

enum CareStatus {
  nominated('NOMINATED', 'Indicado'),
  inCare('IN_CARE', 'Em atendimento'),
  finished('FINISHED', 'Finalizado');

  const CareStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CareStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => nominated,
  );
}

enum CareRecordStatus {
  started('STARTED', 'Iniciado', Color(0xFFFFADAD), Color(0xFFE00000)),
  inProgress(
    'IN_PROGRESS',
    'Em atendimento',
    Color(0xFFF9BC8A),
    Color(0xFFF08A24),
  ),
  finished('FINISHED', 'Finalizado', Color(0xFFB7F5BE), Color(0xFF34C759));

  const CareRecordStatus(this.apiValue, this.label, this.background, this.dot);

  final String apiValue;
  final String label;
  final Color background;
  final Color dot;

  static CareRecordStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => started,
  );
}

enum FinishReason {
  helped('HELPED', 'Ajudado com sucesso'),
  partiallyHelped('PARTIALLY_HELPED', 'Ajudado parcialmente'),
  awaitingReturn('AWAITING_RETURN', 'Aguardando retorno'),
  unsuccessfulAttempt('UNSUCCESSFUL_ATTEMPT', 'Tentativa sem sucesso'),
  couldNotHelp('COULD_NOT_HELP', 'Não foi possível ajudar'),
  notFound('NOT_FOUND', 'Não foi possível localizar'),
  referredElsewhere('REFERRED_ELSEWHERE', 'Encaminhado para outra instituição');

  const FinishReason(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static FinishReason? fromApi(String? value) {
    for (final reason in values) {
      if (reason.apiValue == value) return reason;
    }
    return null;
  }
}

class CareCase {
  const CareCase({
    required this.id,
    required this.fullName,
    required this.urgency,
    required this.status,
    this.age,
    this.gender,
    this.finishReason,
    this.needs = const [],
    this.notes = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.latitude,
    this.longitude,
    this.createdAt,
    this.careStartedAt,
    this.careUpdatedAt,
    this.organizationName,
    this.distanceKm,
  });

  final int id;
  final String fullName;
  final Urgency urgency;
  final CareStatus status;
  final int? age;
  final String? gender;
  final FinishReason? finishReason;
  final List<String> needs;
  final String notes;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? careStartedAt;
  final DateTime? careUpdatedAt;
  final String? organizationName;
  final double? distanceKm;

  String get cityLabel =>
      [city, state].where((part) => part.isNotEmpty).join(' - ');

  String get region => neighborhood.isNotEmpty ? neighborhood : cityLabel;

  String get addressLabel => [
    number.isEmpty ? street : '$street, $number',
    CepInputFormatter.display(zipCode),
  ].where((part) => part.isNotEmpty).join(' - ');

  String get genderLabel => switch (gender) {
    'MALE' => 'Masculino',
    'FEMALE' => 'Feminino',
    'OTHER' => 'Outro',
    _ => 'Não informado',
  };

  bool get hasLocation => latitude != null && longitude != null;

  int? daysWithoutUpdate(DateTime now) {
    final updated = careUpdatedAt;
    return updated == null ? null : now.difference(updated).inDays;
  }
}

class CareRecord {
  const CareRecord({
    required this.id,
    required this.number,
    required this.status,
    required this.occurredAt,
    this.situation,
    this.actionTaken,
    this.referral,
    this.nextStep,
    this.summary,
    this.note,
    this.finishReason,
  });

  final int id;
  final int number;
  final CareRecordStatus status;
  final DateTime occurredAt;
  final String? situation;
  final String? actionTaken;
  final String? referral;
  final String? nextStep;
  final String? summary;
  final String? note;
  final FinishReason? finishReason;

  String get headline =>
      summary ?? actionTaken ?? situation ?? nextStep ?? status.label;
}

class CareCaseDetail {
  const CareCaseDetail({required this.person, required this.records});

  final CareCase person;
  final List<CareRecord> records;

  List<String> get referrals => [
    for (final record in records)
      if (record.referral?.trim().isNotEmpty ?? false) record.referral!.trim(),
  ];
}
