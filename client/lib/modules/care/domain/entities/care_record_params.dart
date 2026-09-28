import 'care_case.dart';

class CareRecordParams {
  const CareRecordParams({
    required this.status,
    required this.occurredAt,
    this.tagIds,
    this.situation = '',
    this.actionTaken = '',
    this.referral = '',
    this.nextStep = '',
    this.summary = '',
    this.note = '',
    this.finishReason,
  });

  final CareRecordStatus status;
  final DateTime occurredAt;
  final List<int>? tagIds;
  final String situation;
  final String actionTaken;
  final String referral;
  final String nextStep;
  final String summary;
  final String note;
  final FinishReason? finishReason;
}
