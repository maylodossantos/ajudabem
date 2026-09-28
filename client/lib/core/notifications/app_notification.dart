enum NotificationType {
  caseNominated('CASE_NOMINATED'),
  caseAssumed('CASE_ASSUMED'),
  caseFinished('CASE_FINISHED'),
  campaignCreated('CAMPAIGN_CREATED'),
  actionCreated('ACTION_CREATED'),
  volunteerApplied('VOLUNTEER_APPLIED'),
  applicationAccepted('APPLICATION_ACCEPTED'),
  organizationApproved('ORGANIZATION_APPROVED'),
  organizationRejected('ORGANIZATION_REJECTED'),
  unknown('');

  const NotificationType(this.apiValue);

  final String apiValue;

  static NotificationType fromApi(String? value) => values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => unknown,
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.targetId,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? value) =>
        value is String ? DateTime.tryParse(value) : null;

    return AppNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: NotificationType.fromApi(json['type'] as String?),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      targetId: (json['targetId'] as num?)?.toInt(),
      createdAt: date(json['createdAt']) ?? DateTime.now(),
      readAt: date(json['readAt']),
    );
  }

  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final int? targetId;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  AppNotification read() => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    targetId: targetId,
    createdAt: createdAt,
    readAt: readAt ?? DateTime.now(),
  );
}
