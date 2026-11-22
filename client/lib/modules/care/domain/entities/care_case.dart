import 'package:flutter/material.dart';

import '../../../../core/widgets/app_badge.dart';

import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/theme/app_colors.dart';

enum Urgency {
  high('HIGH', 'Alta', AppColors.urgencyHigh),
  medium('MEDIUM', 'Média', AppColors.warning),
  low('LOW', 'Baixa', AppColors.success),
  pending(null, 'Em triagem', AppColors.urgencyPending);

  const Urgency(this.apiValue, this.label, this.color);

  AppTone get tone => switch (this) {
    high => AppTone.danger,
    medium => AppTone.warning,
    low => AppTone.success,
    pending => AppTone.neutral,
  };

  String get badgeLabel =>
      this == pending ? 'Em triagem' : 'Urgência ${label.toLowerCase()}';

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
  inCare('IN_CARE', 'Em atendimento', 'Em atendimento', AppTone.warning),
  referred('REFERRED', 'Encaminhar', 'Encaminhado', AppTone.info),
  unsuccessfulAttempt(
    'UNSUCCESSFUL_ATTEMPT',
    'Tentativa sem sucesso',
    'Tentativa sem sucesso',
    AppTone.danger,
  ),
  awaitingReturn(
    'AWAITING_RETURN',
    'Aguardando retorno',
    'Aguardando retorno',
    AppTone.neutral,
  ),
  progressUpdate(
    'PROGRESS_UPDATE',
    'Registrar andamento',
    'Andamento registrado',
    AppTone.warning,
  ),
  finished('FINISHED', 'Finalizar atendimento', 'Finalizado', AppTone.success);

  const CareRecordStatus(this.apiValue, this.action, this.label, this.tone);

  final String apiValue;
  final String action;
  final String label;
  final AppTone tone;

  Color get background => tone.soft;
  Color get dot => tone.strong;

  static const firstActions = [inCare, referred, unsuccessfulAttempt];
  static const followUpActions = [
    progressUpdate,
    awaitingReturn,
    unsuccessfulAttempt,
  ];

  static List<CareRecordStatus> actionsFor({required bool firstRecord}) =>
      firstRecord ? firstActions : followUpActions;

  bool get asksSituation => this == inCare || this == referred;

  bool get asksActionTaken =>
      this == inCare ||
      this == unsuccessfulAttempt ||
      this == awaitingReturn ||
      this == progressUpdate;

  bool get asksReferral =>
      this == inCare || this == referred || this == progressUpdate;

  bool get asksNextStep =>
      this == unsuccessfulAttempt ||
      this == awaitingReturn ||
      this == progressUpdate;

  String get actionTakenLabel => switch (this) {
    unsuccessfulAttempt => 'O que foi tentado',
    _ => 'Ação realizada',
  };

  String get referralLabel =>
      this == referred ? 'Para onde foi encaminhado' : 'Encaminhamento';

  String get nextStepLabel => switch (this) {
    unsuccessfulAttempt => 'Próxima tentativa',
    awaitingReturn => 'Retorno esperado',
    _ => 'Próxima ação',
  };

  static CareRecordStatus fromApi(String? value) => switch (value) {
    'STARTED' => inCare,
    'IN_PROGRESS' => progressUpdate,
    _ => values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => progressUpdate,
    ),
  };
}

enum FinishReason {
  helped('HELPED', 'Ajudado com sucesso'),
  partiallyHelped('PARTIALLY_HELPED', 'Ajudado parcialmente'),
  referredElsewhere('REFERRED_ELSEWHERE', 'Encaminhado para outra instituição'),
  couldNotHelp('COULD_NOT_HELP', 'Não foi possível ajudar'),
  notFound('NOT_FOUND', 'Não foi possível localizar');

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
    this.locationDescription = '',
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
  final String locationDescription;

  String get cityLabel =>
      [city, state].where((part) => part.isNotEmpty).join(' - ');

  String get region => neighborhood.isNotEmpty ? neighborhood : cityLabel;

  String get addressLabel => street.isEmpty && locationDescription.isNotEmpty
      ? 'Aproximado: $locationDescription'
      : [
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

class RiskTriage {
  const RiskTriage({
    required this.justification,
    required this.model,
    this.triagedAt,
  });

  final String justification;
  final String model;
  final DateTime? triagedAt;
}

class CareCaseDetail {
  const CareCaseDetail({
    required this.person,
    required this.records,
    this.triage,
  });

  final CareCase person;
  final List<CareRecord> records;
  final RiskTriage? triage;

  List<String> get referrals => [
    for (final record in records)
      if (record.referral?.trim().isNotEmpty ?? false) record.referral!.trim(),
  ];
}
