import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/presentation/stores/organization_review_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../organization_test_doubles.dart';

void main() {
  test('starts on the data step of a pending request', () {
    final store = OrganizationReviewStore(FakeOrganizationRepository())
      ..init(organizationWith());

    expect(store.step, OrganizationReviewStoreBase.dataStep);
    expect(store.organization!.status, OrganizationStatus.pending);
  });

  test('approving updates the request with the API answer', () async {
    final repository = FakeOrganizationRepository();
    final store = OrganizationReviewStore(repository)..init(organizationWith());

    expect(await store.approve('jwt'), isTrue);
    expect(repository.approvedId, 5);
    expect(store.organization!.status, OrganizationStatus.approved);
    expect(store.isSubmitting, isFalse);
  });

  test('rejecting sends the reason and note', () async {
    final repository = FakeOrganizationRepository();
    final store = OrganizationReviewStore(repository)..init(organizationWith());

    expect(
      await store.reject(RejectionReason.dataMismatch, 'CNPJ diferente', 'jwt'),
      isTrue,
    );
    expect(repository.rejected, (
      5,
      RejectionReason.dataMismatch,
      'CNPJ diferente',
    ));
    expect(store.organization!.status, OrganizationStatus.rejected);
  });

  test('keeps the request and shows the error when the API refuses', () async {
    final store = OrganizationReviewStore(
      FakeOrganizationRepository(
        error: const AppException('Esta solicitação já foi analisada.'),
      ),
    )..init(organizationWith());

    expect(await store.approve('jwt'), isFalse);
    expect(store.errorMessage, 'Esta solicitação já foi analisada.');
    expect(store.organization!.status, OrganizationStatus.pending);
  });
}
