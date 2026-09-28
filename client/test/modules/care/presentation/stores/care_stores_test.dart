import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/presentation/stores/care_list_store.dart';
import 'package:ajuda_bem/modules/care/presentation/stores/care_record_form_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../care_test_doubles.dart';

void main() {
  group('CareListStore', () {
    test('loads each mode from its own endpoint', () async {
      final repository = FakeCareRepository(
        nominatedCases: [careCase(id: 1)],
        myCaseList: [careCase(id: 2, status: CareStatus.inCare)],
      );
      final store = CareListStore(repository);

      await store.load('jwt', mode: CareListMode.nominated);
      expect(store.visibleCases.map((person) => person.id), [1]);

      await store.load('jwt', mode: CareListMode.myCases);
      expect(store.visibleCases.map((person) => person.id), [2]);
    });

    test('assuming removes the person from the nominated list', () async {
      final repository = FakeCareRepository(
        nominatedCases: [careCase(id: 1), careCase(id: 2)],
      );
      final store = CareListStore(repository);
      await store.load('jwt');

      expect(await store.assume(1, 'jwt'), isTrue);

      expect(repository.assumed, [1]);
      expect(store.cases.map((person) => person.id), [2]);
      expect(store.isAssuming(1), isFalse);
    });

    test(
      'keeps the person and exposes the error when assuming fails',
      () async {
        final repository = FakeCareRepository(nominatedCases: [careCase(id: 1)])
          ..failure = const AppException(
            'Outra ONG já assumiu este atendimento.',
          );
        final store = CareListStore(repository);
        await store.load('jwt');

        expect(await store.assume(1, 'jwt'), isFalse);

        expect(store.cases, hasLength(1));
        expect(store.errorMessage, 'Outra ONG já assumiu este atendimento.');
      },
    );
  });

  group('CareRecordFormStore', () {
    CareRecordFormStore startedStore({bool firstRecord = true}) {
      final repository = FakeCareRepository(
        details: {
          1: CareCaseDetail(
            person: careCase(status: CareStatus.inCare),
            records: const [],
          ),
        },
      );
      return CareRecordFormStore(repository)
        ..startWith(careCase(), firstRecord: firstRecord)
        ..setDate('02/09/2026')
        ..setTime('14:30');
    }

    test('starts with the person needs and the right status', () {
      expect(startedStore().status, CareRecordStatus.started);
      expect(startedStore().needs, {'Alimentação'});
      expect(
        startedStore(firstRecord: false).status,
        CareRecordStatus.inProgress,
      );
    });

    test('rejects invalid or future moments', () {
      final store = startedStore();
      expect(store.occurredAt, DateTime(2026, 9, 2, 14, 30));
      expect(store.canSubmit, isTrue);

      store.setTime('25:00');
      expect(store.canSubmit, isFalse);

      store
        ..setTime('10:00')
        ..setDate('01/01/2999');
      expect(store.canSubmit, isFalse);
    });

    test('finishing requires a reason', () {
      final store = startedStore()..setStatus(CareRecordStatus.finished);
      expect(store.canSubmit, isFalse);

      store.setFinishReason(FinishReason.helped);
      expect(store.canSubmit, isTrue);
    });

    test('submits the selected needs as tag ids', () async {
      final repository = FakeCareRepository(
        details: {
          1: CareCaseDetail(
            person: careCase(status: CareStatus.inCare),
            records: const [],
          ),
        },
      );
      final store = CareRecordFormStore(repository)
        ..startWith(careCase(), firstRecord: true)
        ..setDate('02/09/2026')
        ..setTime('14:30')
        ..toggleNeed('Moradia')
        ..setReferral('CRAS');

      final detail = await store.submit(
        1,
        'jwt',
        tagIdsOf: (names) => [
          for (final name in names) name == 'Alimentação' ? 1 : 2,
        ],
      );

      expect(detail?.records, hasLength(1));
      final sent = repository.lastRecord!;
      expect(sent.status, CareRecordStatus.started);
      expect(sent.tagIds, unorderedEquals([1, 2]));
      expect(sent.referral, 'CRAS');
      expect(sent.finishReason, isNull);
    });
  });
}
