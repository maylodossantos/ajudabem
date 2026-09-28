import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../care_test_doubles.dart';

void main() {
  final cases = [
    careCase(id: 1, urgency: Urgency.low, distanceKm: 1),
    careCase(
      id: 2,
      fullName: 'João Lima',
      urgency: Urgency.high,
      distanceKm: 8,
      needs: ['Moradia'],
    ),
    careCase(id: 3, urgency: Urgency.high, distanceKm: 3),
    careCase(id: 4, urgency: Urgency.pending, distanceKm: null, needs: []),
  ];

  test('sorts by urgency first and then by distance', () {
    final ids = const CareFilter().apply(cases).map((person) => person.id);

    expect(ids, [3, 2, 1, 4]);
  });

  test('combines search, urgency, need and distance filters', () {
    expect(const CareFilter(search: 'joão').apply(cases).map((p) => p.id), [2]);
    expect(
      const CareFilter(urgencies: {Urgency.high}).apply(cases).map((p) => p.id),
      [3, 2],
    );
    expect(const CareFilter(needs: {'Moradia'}).apply(cases).map((p) => p.id), [
      2,
    ]);
    expect(
      const CareFilter().withMaxDistance(5).apply(cases).map((p) => p.id),
      [3, 1],
    );
  });

  test('options only list what exists in the cases', () {
    final options = CareOptions.from(cases);

    expect(options.urgencies, {Urgency.low, Urgency.high, Urgency.pending});
    expect(options.needs, {'Alimentação', 'Moradia'});
    expect(options.hasDistances, isTrue);
    expect(options.finishReasons, isEmpty);
  });
}
