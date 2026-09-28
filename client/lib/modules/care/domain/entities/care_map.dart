import 'care_case.dart';

enum MapLayer {
  none('Nenhum'),
  all('Todos'),
  urgent('Urgente'),
  inCare('Em atendimento');

  const MapLayer(this.label);

  final String label;

  List<CareCase> apply(List<CareCase> cases) => switch (this) {
    MapLayer.none => const [],
    MapLayer.all => cases,
    MapLayer.urgent =>
      cases.where((person) => person.urgency == Urgency.high).toList(),
    MapLayer.inCare =>
      cases.where((person) => person.status == CareStatus.inCare).toList(),
  };
}

enum MapMode { foci, people }

class CareFocus {
  const CareFocus({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.count,
    required this.urgency,
  });

  final String label;
  final double latitude;
  final double longitude;
  final int count;
  final Urgency urgency;

  static List<CareFocus> of(List<CareCase> cases) {
    final groups = <String, List<CareCase>>{};
    for (final person in cases.where((person) => person.hasLocation)) {
      final key = person.neighborhood.isNotEmpty
          ? '${person.neighborhood}|${person.city}'.toLowerCase()
          : '${(person.latitude! * 100).round()}|${(person.longitude! * 100).round()}';
      groups.putIfAbsent(key, () => []).add(person);
    }

    return [
      for (final people in groups.values)
        CareFocus(
          label: people.first.region,
          latitude:
              people.map((person) => person.latitude!).reduce((a, b) => a + b) /
              people.length,
          longitude:
              people
                  .map((person) => person.longitude!)
                  .reduce((a, b) => a + b) /
              people.length,
          count: people.length,
          urgency: people
              .map((person) => person.urgency)
              .reduce((a, b) => a.index <= b.index ? a : b),
        ),
    ];
  }
}
