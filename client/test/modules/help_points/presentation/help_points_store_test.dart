import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/geo/geo_point.dart';
import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point.dart';
import 'package:ajuda_bem/modules/help_points/domain/entities/help_point_filter.dart';
import 'package:ajuda_bem/modules/help_points/presentation/stores/help_point_form_store.dart';
import 'package:ajuda_bem/modules/help_points/presentation/stores/help_points_store.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';

import '../help_point_test_doubles.dart';

class _NoUpload implements ImageUploadService {
  @override
  Future<String> uploadImage(XFile file) async => 'https://i.ibb.co/x.png';
}

void main() {
  group('HelpPointsStore', () {
    final near = helpPoint(id: 1, location: const GeoPoint(-24.9560, -53.4560));
    final far = helpPoint(id: 2, location: const GeoPoint(-24.9207, -53.4388));

    test('loads the points and shows newest first', () async {
      final store = HelpPointsStore(
        FakeHelpPointRepository(points: [near, far]),
        FakeLocationService(position: cascavelCenter),
      );

      await store.load();

      expect(store.visiblePoints.map((point) => point.id), [2, 1]);
      expect(store.distanceKmTo(near), isNull, reason: 'no location asked yet');
    });

    test(
      '"Próximos de você" asks for the location once and sorts by it',
      () async {
        final location = FakeLocationService(position: cascavelCenter);
        final store = HelpPointsStore(
          FakeHelpPointRepository(points: [near, far]),
          location,
        );
        await store.load();

        await store.toggleNearby();
        expect(store.isNearbyActive, isTrue);
        expect(store.visiblePoints.map((point) => point.id), [1, 2]);
        expect(store.distanceKmTo(near), lessThan(1));

        await store.toggleNearby();
        await store.toggleNearby();
        expect(location.calls, 1);
      },
    );

    test('shows why the location is unavailable and keeps the list', () async {
      final store = HelpPointsStore(
        FakeHelpPointRepository(points: [near, far]),
        FakeLocationService(errorMessage: 'Permita o acesso à localização.'),
      );
      await store.load();

      await store.applyFilter(const HelpPointFilter(maxDistanceKm: 5));

      expect(store.locationError, 'Permita o acesso à localização.');
      expect(store.visiblePoints, hasLength(2));
    });

    test('quick chips toggle their whole group of types', () {
      final store = HelpPointsStore(
        FakeHelpPointRepository(),
        FakeLocationService(position: cascavelCenter),
      );
      const shelter = {AssistanceType.shelter, AssistanceType.overnight};

      store.toggleTypes(shelter);
      expect(store.filter.types, shelter);
      store.toggleTypes(shelter);
      expect(store.filter.types, isEmpty);

      store.toggleOrganizationType(HelpPointOrganizationType.ngo);
      expect(store.hasOrganizationType(HelpPointOrganizationType.ngo), isTrue);
    });

    test('delete removes the point or exposes the error', () async {
      final repository = FakeHelpPointRepository(points: [near, far]);
      final store = HelpPointsStore(repository, FakeLocationService());
      await store.load();

      expect(await store.delete(1, 'jwt'), isTrue);
      expect(store.points.map((point) => point.id), [2]);

      final failing = HelpPointsStore(
        FakeHelpPointRepository(error: const AppException('Sem permissão.')),
        FakeLocationService(),
      );
      expect(await failing.delete(1, 'jwt'), isFalse);
      expect(failing.errorMessage, 'Sem permissão.');
    });
  });

  group('HelpPointFormStore', () {
    HelpPointFormStore filled(FakeHelpPointRepository repository) =>
        HelpPointFormStore(repository, _NoUpload())
          ..setName('Albergue Municipal Esperança')
          ..setOrganizationType(HelpPointOrganizationType.municipalShelter)
          ..toggleService(AssistanceType.shelter)
          ..setStreet('R. Rio Borá')
          ..setCity('Cascavel')
          ..setState('PR');

    test('needs name, type, a service and the address', () {
      final form = filled(FakeHelpPointRepository());
      expect(form.canSubmit, isTrue);

      form.toggleService(AssistanceType.shelter);
      expect(form.canSubmit, isFalse, reason: 'no service left');

      form
        ..toggleService(AssistanceType.food)
        ..setZipCode('85814-50');
      expect(form.canSubmit, isFalse, reason: 'half-typed CEP');
    });

    test('edits the week and sends it in order with digits only', () async {
      final repository = FakeHelpPointRepository();
      final form = filled(repository)
        ..setPhone('(11) 3942-7810')
        ..setZipCode('85814-508')
        ..setDayOpen(DateTime.friday, true)
        ..setDayTimes(DateTime.friday, opensAt: 18 * 60, closesAt: 7 * 60)
        ..applyToAllDays(DateTime.friday)
        ..setDayAllDay(DateTime.sunday, true)
        ..setDayOpen(DateTime.saturday, false);

      expect(await form.submit('jwt'), isTrue);

      final params = repository.created!;
      expect(params.phone, '1139427810');
      expect(params.zipCode, '85814508');
      expect(params.openingHours.map((hours) => hours.weekday), [
        1,
        2,
        3,
        4,
        5,
        7,
      ]);
      expect(params.openingHours.first.closesAt, 7 * 60);
      expect(params.openingHours.last.isAllDay, isTrue);
    });

    test('editing updates the same point', () async {
      final repository = FakeHelpPointRepository();
      final form = HelpPointFormStore(repository, _NoUpload())
        ..populate(helpPoint(id: 5, openingHours: everyDay(0, 0)));

      expect(form.isEditing, isTrue);
      expect(form.hours, hasLength(7));
      await form.submit('jwt');

      expect(repository.updated!.$1, 5);
      expect(form.saved!.id, 5);
    });
  });
}
