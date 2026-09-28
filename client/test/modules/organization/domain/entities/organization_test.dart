import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 6, 20, 12);

  Organization rejected({DateTime? availableAt}) => Organization(
    id: 1,
    corporateName: 'Instituto Esperança LTDA',
    tradeName: 'Instituto Esperança',
    cnpj: '11222333000181',
    status: OrganizationStatus.rejected,
    resubmitAvailableAt: availableAt,
  );

  test('a rejected organization waits until the resubmission date', () {
    final waiting = rejected(availableAt: now.add(const Duration(hours: 50)));

    expect(waiting.canResubmitAt(now), isFalse);
    expect(waiting.daysUntilResubmit(now), 3);
  });

  test('a rejected organization can ask again once the wait is over', () {
    final ready = rejected(
      availableAt: now.subtract(const Duration(minutes: 1)),
    );

    expect(ready.canResubmitAt(now), isTrue);
    expect(ready.daysUntilResubmit(now), 0);
  });

  test('only rejected organizations can resubmit', () {
    const pending = Organization(
      id: 1,
      corporateName: 'x',
      tradeName: 'x',
      cnpj: '11222333000181',
      status: OrganizationStatus.pending,
    );

    expect(pending.canResubmitAt(now), isFalse);
  });

  test('enums read the API values', () {
    expect(OrganizationStatus.fromApi('APPROVED'), OrganizationStatus.approved);
    expect(
      OrganizationDocumentType.fromApi('BOARD_ELECTION_MINUTES'),
      OrganizationDocumentType.boardElectionMinutes,
    );
    expect(OrganizationDocumentType.fromApi('SOMETHING_NEW'), isNull);
    expect(
      RejectionReason.fromApi('DATA_MISMATCH'),
      RejectionReason.dataMismatch,
    );
  });
}
