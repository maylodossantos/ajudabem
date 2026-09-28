enum CampaignCategory {
  food('FOOD', 'Alimentos'),
  clothing('CLOTHING', 'Roupas'),
  hygiene('HYGIENE', 'Higiene'),
  health('HEALTH', 'Saúde'),
  housing('HOUSING', 'Moradia'),
  education('EDUCATION', 'Educação'),
  animals('ANIMALS', 'Animais'),
  other('OTHER', 'Outros');

  const CampaignCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CampaignCategory fromApi(String? value) => values.firstWhere(
    (category) => category.apiValue == value,
    orElse: () => other,
  );
}

enum InitiativeStatus {
  active('ACTIVE'),
  finished('FINISHED');

  const InitiativeStatus(this.apiValue);

  final String apiValue;

  static InitiativeStatus fromApi(String? value) =>
      value == finished.apiValue ? finished : active;
}

class InitiativeArgs {
  const InitiativeArgs(this.id, {this.manage = false});

  final int id;
  final bool manage;

  static InitiativeArgs of(Object? data) => switch (data) {
    final InitiativeArgs args => args,
    final int id => InitiativeArgs(id),
    _ => const InitiativeArgs(0),
  };
}

class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.donationInfo = '',
    this.subtitle = '',
    this.goalAmount,
    this.deadline,
    this.coverImage,
    this.organizationName = '',
  });

  final int id;
  final String title;
  final String donationInfo;
  final String subtitle;
  final String description;
  final CampaignCategory category;
  final double? goalAmount;
  final DateTime? deadline;
  final String? coverImage;
  final InitiativeStatus status;
  final String organizationName;

  bool get isActive => status == InitiativeStatus.active;

  int? daysLeft(DateTime now) {
    final end = deadline;
    if (end == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(end.year, end.month, end.day).difference(today).inDays;
  }

  String deadlineLabel(DateTime now) {
    if (!isActive) return 'Campanha finalizada.';
    final days = daysLeft(now);
    if (days == null) return 'Sem prazo definido.';
    if (days < 0) return 'Prazo encerrado.';
    if (days == 0) return 'Último dia!';
    return days == 1 ? '1 dia restante.' : '$days dias restantes.';
  }
}

class CampaignParams {
  const CampaignParams({
    required this.title,
    required this.description,
    required this.category,
    this.donationInfo = '',
    this.subtitle = '',
    this.goalAmount,
    this.deadline,
    this.coverImage,
  });

  final String title;
  final String donationInfo;
  final String subtitle;
  final String description;
  final CampaignCategory category;
  final double? goalAmount;
  final DateTime? deadline;
  final String? coverImage;
}
