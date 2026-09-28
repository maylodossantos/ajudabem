import 'package:ajuda_bem/core/geo/geo_point.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../help_point_test_doubles.dart';

void main() {
  group('opening hours', () {
    const overnight = OpeningHours(
      weekday: DateTime.monday,
      opensAt: 18 * 60,
      closesAt: 7 * 60,
    );

    test('an overnight shelter is open late that day and early the next', () {
      expect(overnight.isOpenAt(monday.add(const Duration(hours: 20))), isTrue);
      expect(
        overnight.isOpenAt(monday.add(const Duration(days: 1, hours: 6))),
        isTrue,
        reason: 'Tuesday 06h is still Monday night',
      );
      expect(
        overnight.isOpenAt(monday.add(const Duration(hours: 12))),
        isFalse,
      );
      expect(
        overnight.isOpenAt(monday.add(const Duration(days: 1, hours: 8))),
        isFalse,
      );
      expect(overnight.coversNight, isTrue);
    });

    test('a regular day only counts between opening and closing', () {
      const clinic = OpeningHours(
        weekday: DateTime.monday,
        opensAt: 8 * 60,
        closesAt: 17 * 60,
      );

      expect(clinic.isOpenAt(monday.add(const Duration(hours: 9))), isTrue);
      expect(clinic.isOpenAt(monday.add(const Duration(hours: 17))), isFalse);
      expect(clinic.coversNight, isFalse);
    });

    test('schedule lines group days with the same hours', () {
      final shelter = helpPoint(
        openingHours: [
          for (var day = DateTime.monday; day <= DateTime.friday; day++)
            OpeningHours(weekday: day, opensAt: 18 * 60, closesAt: 7 * 60),
          const OpeningHours(
            weekday: DateTime.saturday,
            opensAt: 18 * 60,
            closesAt: 8 * 60,
          ),
          const OpeningHours(
            weekday: DateTime.sunday,
            opensAt: 18 * 60,
            closesAt: 8 * 60,
          ),
        ],
      );

      expect(shelter.scheduleLines, [
        'Segunda a Sexta: 18h00 às 07h00',
        'Sábado e Domingo: 18h00 às 08h00',
      ]);
      expect(helpPoint(openingHours: everyDay(0, 0)).scheduleLines, [
        'Todos os dias: 24 horas',
      ]);
    });
  });

  group('filter', () {
    final shelter = helpPoint(
      id: 1,
      openingHours: everyDay(18 * 60, 7 * 60),
      location: const GeoPoint(-24.9207, -53.4388),
    );
    final ngoKitchen = helpPoint(
      id: 2,
      name: 'Sopão Solidário',
      services: [AssistanceType.food],
      organizationType: HelpPointOrganizationType.ngo,
      openingHours: const [
        OpeningHours(
          weekday: DateTime.monday,
          opensAt: 11 * 60,
          closesAt: 14 * 60,
        ),
      ],
      location: const GeoPoint(-24.9560, -53.4560),
    );
    final upa = helpPoint(
      id: 3,
      name: 'UPA Veneza',
      services: [AssistanceType.medical],
      organizationType: HelpPointOrganizationType.publicHealth,
      openingHours: everyDay(0, 0),
    );
    final all = [shelter, ngoKitchen, upa];

    List<int> ids(HelpPointFilter filter, {DateTime? now, GeoPoint? origin}) =>
        filter
            .apply(
              all,
              now: now ?? monday.add(const Duration(hours: 12)),
              origin: origin,
            )
            .map((point) => point.id)
            .toList();

    test('no filter shows everything, newest first', () {
      expect(ids(const HelpPointFilter()), [3, 2, 1]);
    });

    test('type and organization narrow down; options in a group add up', () {
      expect(
        ids(
          const HelpPointFilter(
            types: {AssistanceType.food, AssistanceType.medical},
          ),
        ),
        [3, 2],
      );
      expect(
        ids(
          const HelpPointFilter(
            types: {AssistanceType.food, AssistanceType.medical},
            organizationTypes: {HelpPointOrganizationType.ngo},
          ),
        ),
        [2],
      );
    });

    test('availability uses the moment it is checked', () {
      const openNow = HelpPointFilter(
        availability: {HelpPointAvailability.openNow},
      );
      expect(ids(openNow), [3, 2], reason: 'Monday 12h: kitchen and UPA');
      expect(ids(openNow, now: monday.add(const Duration(hours: 22))), [
        3,
        1,
      ], reason: 'Monday 22h: shelter and UPA');
      expect(
        ids(
          const HelpPointFilter(availability: {HelpPointAvailability.allDay}),
        ),
        [3],
      );
      expect(
        ids(const HelpPointFilter(availability: {HelpPointAvailability.night})),
        [3, 1],
      );
    });

    test(
      'nearest sorts by distance and the limit drops far or unknown ones',
      () {
        expect(
          ids(
            const HelpPointFilter(sort: HelpPointSort.nearest),
            origin: cascavelCenter,
          ),
          [2, 1, 3],
          reason: 'the UPA has no coordinates, so it goes last',
        );
        expect(
          ids(const HelpPointFilter(maxDistanceKm: 2), origin: cascavelCenter),
          [2],
        );
        expect(ids(const HelpPointFilter(maxDistanceKm: 2)), [
          3,
          2,
          1,
        ], reason: 'without the user location the limit is ignored');
      },
    );
  });

  test('filter options only list what at least one point has', () {
    final options = HelpPointOptions.from([
      helpPoint(
        services: [AssistanceType.medical],
        openingHours: everyDay(0, 0),
      ),
      helpPoint(
        id: 2,
        services: [AssistanceType.psychological],
        organizationType: HelpPointOrganizationType.publicHealth,
      ),
    ], monday);

    expect(options.types, {
      AssistanceType.medical,
      AssistanceType.psychological,
    });
    expect(options.organizationTypes, {
      HelpPointOrganizationType.municipalShelter,
      HelpPointOrganizationType.publicHealth,
    });
    expect(options.availability, {
      HelpPointAvailability.night,
      HelpPointAvailability.openToday,
      HelpPointAvailability.openNow,
      HelpPointAvailability.allDay,
    });
    expect(options.hasLocations, isFalse);
    expect(options.offersAny({AssistanceType.shelter}), isFalse);
  });

  test('distances are formatted for people', () {
    expect(GeoPoint.formatKm(0.85), '850 m');
    expect(GeoPoint.formatKm(3.44), '3,4 km');
    expect(GeoPoint.formatKm(12.4), '12 km');
    expect(
      cascavelCenter.distanceKmTo(const GeoPoint(-24.9207, -53.4388)),
      closeTo(4.2, 0.3),
    );
  });
}
