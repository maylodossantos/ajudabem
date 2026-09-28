import 'care_case.dart';

class CareFilter {
  const CareFilter({
    this.urgencies = const {},
    this.maxDistanceKm,
    this.needs = const {},
    this.statuses = const {},
    this.finishReasons = const {},
    this.search = '',
  });

  final Set<Urgency> urgencies;
  final double? maxDistanceKm;
  final Set<String> needs;
  final Set<CareStatus> statuses;
  final Set<FinishReason> finishReasons;
  final String search;

  bool get isEmpty =>
      urgencies.isEmpty &&
      maxDistanceKm == null &&
      needs.isEmpty &&
      statuses.isEmpty &&
      finishReasons.isEmpty;

  CareFilter copyWith({
    Set<Urgency>? urgencies,
    Set<String>? needs,
    Set<CareStatus>? statuses,
    Set<FinishReason>? finishReasons,
    String? search,
  }) {
    return CareFilter(
      urgencies: urgencies ?? this.urgencies,
      maxDistanceKm: maxDistanceKm,
      needs: needs ?? this.needs,
      statuses: statuses ?? this.statuses,
      finishReasons: finishReasons ?? this.finishReasons,
      search: search ?? this.search,
    );
  }

  CareFilter withMaxDistance(double? km) => CareFilter(
    urgencies: urgencies,
    maxDistanceKm: km,
    needs: needs,
    statuses: statuses,
    finishReasons: finishReasons,
    search: search,
  );

  List<CareCase> apply(List<CareCase> cases) {
    final term = search.trim().toLowerCase();

    final visible = cases.where((person) {
      if (term.isNotEmpty &&
          ![
            person.fullName,
            person.region,
            person.organizationName ?? '',
            ...person.needs,
          ].any((text) => text.toLowerCase().contains(term))) {
        return false;
      }
      if (urgencies.isNotEmpty && !urgencies.contains(person.urgency)) {
        return false;
      }
      if (needs.isNotEmpty && !person.needs.any(needs.contains)) return false;
      if (statuses.isNotEmpty && !statuses.contains(person.status)) {
        return false;
      }
      if (finishReasons.isNotEmpty &&
          !finishReasons.contains(person.finishReason)) {
        return false;
      }
      final limit = maxDistanceKm;
      final distance = person.distanceKm;
      if (limit != null && (distance == null || distance > limit)) {
        return false;
      }
      return true;
    }).toList();

    visible.sort((a, b) {
      final byUrgency = a.urgency.index.compareTo(b.urgency.index);
      if (byUrgency != 0) return byUrgency;
      return (a.distanceKm ?? double.infinity).compareTo(
        b.distanceKm ?? double.infinity,
      );
    });
    return visible;
  }
}

class CareOptions {
  CareOptions.from(List<CareCase> cases)
    : urgencies = {for (final person in cases) person.urgency},
      needs = {for (final person in cases) ...person.needs},
      statuses = {for (final person in cases) person.status},
      finishReasons = {for (final person in cases) ?person.finishReason},
      hasDistances = cases.any((person) => person.distanceKm != null);

  final Set<Urgency> urgencies;
  final Set<String> needs;
  final Set<CareStatus> statuses;
  final Set<FinishReason> finishReasons;
  final bool hasDistances;
}
