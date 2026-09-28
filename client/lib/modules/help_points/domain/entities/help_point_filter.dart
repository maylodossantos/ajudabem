import '../../../../core/geo/geo_point.dart';
import 'help_point.dart';

enum HelpPointSort {
  recent('Mais recentes'),
  nearest('Mais próximos');

  const HelpPointSort(this.label);

  final String label;
}

enum HelpPointAvailability {
  night('Atendimento noturno'),
  openToday('Aberto hoje'),
  openNow('Aberto agora'),
  allDay('Atendimento 24h');

  const HelpPointAvailability(this.label);

  final String label;

  bool matches(HelpPoint point, DateTime now) => switch (this) {
    night => point.hasNightService,
    openToday => point.opensOn(now),
    openNow => point.isOpenAt(now),
    allDay => point.isAlwaysOpen,
  };
}

class HelpPointFilter {
  const HelpPointFilter({
    this.types = const {},
    this.maxDistanceKm,
    this.sort = HelpPointSort.recent,
    this.availability = const {},
    this.organizationTypes = const {},
  });

  static const maxDistanceLimitKm = 50.0;

  final Set<AssistanceType> types;

  final double? maxDistanceKm;
  final HelpPointSort sort;
  final Set<HelpPointAvailability> availability;
  final Set<HelpPointOrganizationType> organizationTypes;

  bool get needsLocation =>
      sort == HelpPointSort.nearest || maxDistanceKm != null;

  bool get isEmpty =>
      types.isEmpty &&
      maxDistanceKm == null &&
      sort == HelpPointSort.recent &&
      availability.isEmpty &&
      organizationTypes.isEmpty;

  HelpPointFilter copyWith({
    Set<AssistanceType>? types,
    HelpPointSort? sort,
    Set<HelpPointAvailability>? availability,
    Set<HelpPointOrganizationType>? organizationTypes,
  }) {
    return HelpPointFilter(
      types: types ?? this.types,
      maxDistanceKm: maxDistanceKm,
      sort: sort ?? this.sort,
      availability: availability ?? this.availability,
      organizationTypes: organizationTypes ?? this.organizationTypes,
    );
  }

  HelpPointFilter withMaxDistance(double? km) => HelpPointFilter(
    types: types,
    maxDistanceKm: km,
    sort: sort,
    availability: availability,
    organizationTypes: organizationTypes,
  );

  List<HelpPoint> apply(
    List<HelpPoint> points, {
    required DateTime now,
    GeoPoint? origin,
  }) {
    double? distanceOf(HelpPoint point) {
      final location = point.location;
      return origin == null || location == null
          ? null
          : origin.distanceKmTo(location);
    }

    final visible = points.where((point) {
      if (types.isNotEmpty && !point.services.any(types.contains)) {
        return false;
      }
      if (organizationTypes.isNotEmpty &&
          !organizationTypes.contains(point.organizationType)) {
        return false;
      }
      if (availability.isNotEmpty &&
          !availability.any((option) => option.matches(point, now))) {
        return false;
      }
      final limit = maxDistanceKm;
      if (limit != null && origin != null) {
        final distance = distanceOf(point);
        if (distance == null || distance > limit) return false;
      }
      return true;
    }).toList();

    if (sort == HelpPointSort.nearest && origin != null) {
      visible.sort((a, b) {
        final da = distanceOf(a) ?? double.infinity;
        final db = distanceOf(b) ?? double.infinity;
        return da.compareTo(db);
      });
    } else {
      visible.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    }
    return visible;
  }
}

class HelpPointOptions {
  HelpPointOptions.from(List<HelpPoint> points, DateTime now)
    : types = {for (final point in points) ...point.services},
      organizationTypes = {for (final point in points) point.organizationType},
      availability = {
        for (final option in HelpPointAvailability.values)
          if (points.any((point) => option.matches(point, now))) option,
      },
      hasLocations = points.any((point) => point.location != null);

  final Set<AssistanceType> types;
  final Set<HelpPointOrganizationType> organizationTypes;
  final Set<HelpPointAvailability> availability;
  final bool hasLocations;

  bool offersAny(Set<AssistanceType> wanted) => wanted.any(types.contains);
}
